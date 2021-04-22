package handler

import (
	"archive/zip"
	"generate-proto/global"
	"generate-proto/middle"
	"generate-proto/model"
	"github.com/gin-gonic/gin"
	"github.com/labstack/gommon/log"
	"html/template"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"sync"
)

type tableSelected struct {
	TableName       string   `json:"tableName"`       //表名
	TableComment    string   `json:"tableComment"`    //注释
	MiddleTableName string   `json:"middleTableName"` //中间表名
	TableMethod     []string `json:"tableMethod"`     //选中方法
}

type generateReq struct {
	ModelName         string           `json:"modelName"`         // model名
	ConnectDb         string           `json:"connectDb"`         //数据库连接
	IgnoreTablePreFix string           `json:"ignoreTablePrefix"` // 忽略表名前缀
	ProtoType         string           `json:"protoType"`         // normal goproto gogoproto
	ServiceNameType   int              `json:"serviceNameType"`   // 服务名类型
	ServiceName       string           `json:"serviceName"`       // type=0使用ServerName
	TableList         []*tableSelected `json:"tableList"`         // 选中表集合
	FuncLen           int64            `json:"funcLen"`           //有多少个Func type=0使用
}

const (
	// 普通字段
	protoFilePath          = "./template/proto.proto.tpl"
	modelFilePath          = "./template/model.go.tpl"
	serviceHandlerFilePath = "./template/service_handler.go.tpl"
	webHandlerFilePath     = "./template/web_handler.go.tpl"

	//go protobuf字段
	goProtoFilePath          = "./template/go_proto.proto.tpl"
	goModelFilePath          = "./template/go_model.go.tpl"
	goServiceHandlerFilePath = "./template/go_service_handler.go.tpl"
	goWebHandlerFilePath     = "./template/go_web_handler.go.tpl"

	//gogo protobuf字段
	gogoProtoFilePath          = "./template/gogo_proto.proto.tpl"
	gogoModelFilePath          = "./template/gogo_model.go.tpl"
	gogoServiceHandlerFilePath = "./template/gogo_service_handler.go.tpl"
	gogoWebHandlerFilePath     = "./template/gogo_web_handler.go.tpl"

	//markdown
	tableMdFilePath = "./template/table_struct.md.tpl"
	apiMdFilePath   = "./template/api.md.tpl"

	//vue
	vueFilePath = "./template/table.vue.tpl"
)

func GenerateCode(c *gin.Context) {
	param := new(generateReq)
	resp := new(global.Response)
	defer c.JSON(http.StatusOK, resp)

	err := c.ShouldBindJSON(param)
	if err != nil {
		log.Errorf("illegal body: %s", err)
		resp.Code = global.ErrCodeParamInvalid
		resp.Msg = "参数解析失败"
		return
	}

	var (
		gData             *global.GenerateBody
		typeMap           map[string]string // 选择数据库字段转换类型
		goTypeMap         map[string]string //数据库字段转go类型
		protoTpl          *template.Template
		modelTpl          *template.Template
		serviceHandlerTpl *template.Template
		webHandlerTpl     *template.Template
		tableMdTpl        *template.Template
		apiMdTpl          *template.Template
		wg                sync.WaitGroup
		oneService        global.Service
		//vueTpl            *template.Template
	)

	oneService.ServiceName = param.ServiceName
	gData = new(global.GenerateBody)
	gData.TableMap = make(map[string]global.Table)
	gData.ModelName = param.ModelName
	gData.ConnectDb = param.ConnectDb
	goTypeMap = global.NormalType

	tableMdTpl, _ = template.ParseFiles(tableMdFilePath)
	apiMdTpl, _ = template.ParseFiles(apiMdFilePath)
	//vueTpl, err = template.ParseFiles(vueFilePath)

	switch param.ProtoType {
	case "normal":
		typeMap = global.NormalType
		protoTpl, _ = template.ParseFiles(protoFilePath)
		modelTpl, _ = template.ParseFiles(modelFilePath)
		serviceHandlerTpl, _ = template.ParseFiles(serviceHandlerFilePath)
		webHandlerTpl, _ = template.ParseFiles(webHandlerFilePath)
		break
	case "goproto":
		typeMap = global.GoType
		protoTpl, _ = template.ParseFiles(goProtoFilePath)
		modelTpl, _ = template.ParseFiles(goModelFilePath)
		serviceHandlerTpl, _ = template.ParseFiles(goServiceHandlerFilePath)
		webHandlerTpl, _ = template.ParseFiles(goWebHandlerFilePath)
		break
	case "gogoproto": // 考虑实现
		//typeMap = global.GoGoType
		//protoTpl,_ = template.ParseFiles(gogoProtoFilePath)
		//modelTpl,_ = template.ParseFiles(gogoModelFilePath)
		//serviceHandlerTpl,_ = template.ParseFiles(gogoServiceHandlerFilePath)
		//webHandlerTpl,_ = template.ParseFiles(gogoWebHandlerFilePath)
		//break
	default:
		typeMap = global.NormalType
		protoTpl, _ = template.ParseFiles(protoFilePath)
		modelTpl, _ = template.ParseFiles(modelFilePath)
		serviceHandlerTpl, _ = template.ParseFiles(serviceHandlerFilePath)
		webHandlerTpl, _ = template.ParseFiles(webHandlerFilePath)
	}

	//根据选中tableList转换模版实体
	for _, tableParam := range param.TableList {
		wg.Add(1)
		go func(tableName, tableComment string) {
			defer wg.Done()
			tableColList, err := model.DbTableCols{}.GetTableCols(tableName, tableComment)
			if err != nil {
				log.Errorf("[%s] fail", tableName)
			} else {
				var (
					service             global.Service
					table               global.Table
					fieldList           []global.Field
					serviceName         string
					bigHumpTableName    string
					littleHumpTableName string
					createFunc          global.Func
					readFunc            global.Func
					updataFunc          global.Func
					deleteFunc          global.Func
					i                   int
				)
				i = 1
				for _, col := range tableColList {
					_, ignoreOk := global.IgnoreCol[col.ColName]
					_, baseOk := global.BaseCol[col.ColName]
					_, pointerOk := global.NonPointerCol[col.ColName]

					field := global.Field{
						ColNum:            i,
						ColName:           col.ColName,
						BigHumpColName:    middle.Case2Camel(col.ColName),
						LittleHumpColName: middle.LowerFisrt(middle.Case2Camel(col.ColName)),
						ColType:           col.ColType,
						ColTypeName:       typeMap[col.DataType],
						ColTypeNameGo:     goTypeMap[col.DataType],
						ColIsNull:         col.IsNull,
						ColComment:        col.ColComment,
						Ignore:            ignoreOk,
						Base:              baseOk,
						Pointer:           !pointerOk && !ignoreOk, //指针非忽略
					}
					fieldList = append(fieldList, field)
					i++
				}

				bigHumpTableName = middle.IgnorePrefixAnd2Camel(param.IgnoreTablePreFix, tableName)
				littleHumpTableName = middle.LowerFisrt(bigHumpTableName)

				createFunc = global.Func{FuncName: "Create" + bigHumpTableName, RequestName: "Create" + bigHumpTableName + "Request", ResponseName: "Create" + bigHumpTableName + "Response"}
				readFunc = global.Func{FuncName: "Read" + bigHumpTableName, RequestName: "Read" + bigHumpTableName + "Request", ResponseName: "Read" + bigHumpTableName + "Response"}
				updataFunc = global.Func{FuncName: "Update" + bigHumpTableName, RequestName: "Update" + bigHumpTableName + "Request", ResponseName: "Update" + bigHumpTableName + "Response"}
				deleteFunc = global.Func{FuncName: "Delete" + bigHumpTableName, RequestName: "Delete" + bigHumpTableName + "Request", ResponseName: "Delete" + bigHumpTableName + "Response"}

				//待优化 表服务名  单服务名
				if param.ServiceNameType == 1 {
					serviceName = bigHumpTableName + "Service"
					service.ServiceName = serviceName
					service.ServiceComment = tableComment
					service.FuncList = append(service.FuncList, createFunc)
					service.FuncList = append(service.FuncList, readFunc)
					service.FuncList = append(service.FuncList, updataFunc)
					service.FuncList = append(service.FuncList, deleteFunc)
					gData.ServiceList = append(gData.ServiceList, service)
				} else {
					serviceName = param.ServiceName
					oneService.FuncList = append(oneService.FuncList, createFunc)
					oneService.FuncList = append(oneService.FuncList, readFunc)
					oneService.FuncList = append(oneService.FuncList, updataFunc)
					oneService.FuncList = append(oneService.FuncList, deleteFunc)
				}

				table.ModelName = gData.ModelName
				table.ServiceName = serviceName
				table.ConnectDb = gData.ConnectDb
				table.TableName = tableName
				table.BigHumpTableName = bigHumpTableName
				table.LittleHumpTableName = littleHumpTableName
				table.First = littleHumpTableName[0:1]
				table.TableComment = tableComment
				table.ColList = fieldList
				table.CreateFunc = createFunc
				table.ReadFunc = readFunc
				table.UpdateFunc = updataFunc
				table.DeleteFunc = deleteFunc

				gData.TableMap[tableName] = table
				gData.MsgList = append(gData.MsgList, createMsg(fieldList, table, param.IgnoreTablePreFix)...)
			}
		}(tableParam.TableName, tableParam.TableComment)
	}

	//等待表查询转换模板实体
	wg.Wait()

	//待优化 表服务名  单服务名
	if param.ServiceNameType == 1 {

	} else {
		gData.ServiceList = append(gData.ServiceList, oneService)
	}

	//清除上次生成文件
	_ = removeFiles("./res/proto/")
	_ = removeFiles("./res/model/")
	_ = removeFiles("./res/serviceHandler/")
	_ = removeFiles("./res/webHandler/")
	_ = removeFiles("./res/markdown/")
	_ = removeFiles("./res/vue/")

	//生成文件 model serviceHandler webHandler
	for _, tableParam := range param.TableList {
		wg.Add(1)
		go func(tableName string) {
			defer wg.Done()

			ignorePreFixName := middle.IgnorePrefix(param.IgnoreTablePreFix, tableName)
			generate("./res/model/"+ignorePreFixName+".go", modelTpl, gData.TableMap[tableName])
			generate("./res/serviceHandler/"+ignorePreFixName+".go", serviceHandlerTpl, gData.TableMap[tableName])
			generate("./res/webHandler/"+ignorePreFixName+".go", webHandlerTpl, gData.TableMap[tableName])
			generate("./res/markdown/"+ignorePreFixName+".md", apiMdTpl, gData.TableMap[tableName])

			//TODO go template识别字符与vue冲突 {{}} $
			//generate("./res/vue/"+gData.TableMap[tableName].BigHumpTableName+".vue", vueTpl, gData.TableMap[tableName])
		}(tableParam.TableName)
	}

	//生成md
	generate("./res/markdown/"+gData.ModelName+".md", tableMdTpl, gData)
	//生成proto
	generate("./res/proto/"+gData.ModelName+".proto", protoTpl, gData)

	//等待代码生成结束
	wg.Wait()

	//打包文件
	zipName := "res.zip"
	zipDir("./res", "./"+zipName)

	//下载
	//c.Writer.Header().Add("Content-Disposition", "attachment; filename="+zipName)
	//c.Writer.Header().Add("Content-Type", "application/zip, application/octet-stream")
	//c.File(zipName)
	resp.Code = 10000
	resp.Data = gData
}

// fileName写入文件  tmpl模板文件 body模版参数
func generate(fileName string, tmpl *template.Template, body interface{}) {
	file, err := os.OpenFile(fileName, os.O_CREATE|os.O_WRONLY, 0755)
	err = tmpl.Execute(file, body)
	if err != nil {
		log.Error(os.Stderr, "Fatal error: ", err)
		return
	}
}

//清空文件夹内文件保留文件夹
func removeFiles(dirPath string) error {
	d, err := os.Open(dirPath)
	if err != nil {
		//没有就新建
		os.Mkdir(dirPath, os.ModePerm)
	}
	defer d.Close()
	names, err := d.Readdirnames(-1)
	if err != nil {
		return err
	}
	for _, name := range names {
		err = os.RemoveAll(filepath.Join(dirPath, name))
		if err != nil {
			return err
		}
	}
	return nil
}

//打包
func zipDir(srcPath, zipName string) {
	// 预防：旧文件无法覆盖
	os.RemoveAll(zipName)

	// 创建：zip文件
	zipfile, _ := os.Create(zipName)
	defer zipfile.Close()

	// 打开：zip文件
	archive := zip.NewWriter(zipfile)
	defer archive.Close()

	// 遍历路径信息
	filepath.Walk(srcPath, func(path string, info os.FileInfo, _ error) error {

		// 如果是源路径，提前进行下一个遍历
		if path == srcPath {
			return nil
		}

		// 获取：文件头信息
		header, _ := zip.FileInfoHeader(info)
		header.Name = strings.TrimPrefix(path, srcPath+`\`)

		// 判断：文件是不是文件夹
		if info.IsDir() {
			header.Name += `/`
		} else {
			// 设置：zip的文件压缩算法
			header.Method = zip.Deflate
		}

		// 创建：压缩包头部信息
		writer, _ := archive.CreateHeader(header)
		if !info.IsDir() {
			file, _ := os.Open(path)
			defer file.Close()
			io.Copy(writer, file)
		}
		return nil
	})
}

// 生成proto message
func createMsg(fieldList []global.Field, table global.Table, preFix string) (msgList []global.Message) {

	ignorePreFixName := middle.IgnorePrefix(preFix, table.TableName)

	idField := global.Field{
		ColNum:      1,
		ColName:     "id",
		ColTypeName: "int64",
		ColComment:  "pk",
		Ignore:      true,
	}
	idField2 := global.Field{
		ColNum:      2,
		ColName:     "id",
		ColTypeName: "int64",
		ColComment:  "pk",
		Ignore:      true,
	}
	returnField := global.Field{
		ColNum:      1,
		ColName:     "ret",
		ColTypeName: "CommonReturn",
		ColComment:  "回复",
		Ignore:      true,
	}
	infoField := global.Field{
		ColNum:      1,
		ColName:     ignorePreFixName + "_info",
		ColTypeName: table.BigHumpTableName + "Info",
		ColComment:  table.TableComment + "详情",
		Ignore:      true,
	}
	queryField := global.Field{
		ColNum:      1,
		ColName:     "query {QueryByID by_id = 2;Query" + table.BigHumpTableName + "All all = 3;}",
		ColTypeName: "oneof",
		Base:        true, //复用
		ColComment:  "回复",
		Ignore:      true,
	}
	repeatedInfoField := global.Field{
		ColNum:      2,
		ColName:     ignorePreFixName,
		ColTypeName: "repeated " + table.BigHumpTableName,
		ColComment:  table.TableComment,
		Ignore:      true,
	}
	totalField := global.Field{
		ColNum:      3,
		ColName:     "total",
		ColTypeName: "int32",
		ColComment:  "数量",
		Ignore:      true,
	}

	returnFieldList := []global.Field{returnField}

	infoFieldList := []global.Field{}
	queryAllList := []global.Field{}
	tableFieldList := []global.Field{infoField, idField2}

	i := 1
	for _, field := range fieldList {
		_, ignoreOk := global.IgnoreCol[field.ColName]

		if !ignoreOk {
			field := global.Field{
				ColNum:            i,
				ColName:           field.ColName,
				BigHumpColName:    field.BigHumpColName,
				LittleHumpColName: field.LittleHumpColName,
				ColType:           field.ColType,
				ColTypeName:       field.ColTypeName,
				ColTypeNameGo:     field.ColTypeNameGo,
				ColIsNull:         field.ColIsNull,
				ColComment:        field.ColComment,
				Ignore:            ignoreOk,
			}
			infoFieldList = append(infoFieldList, field)
			queryAllList = append(queryAllList, field)
			i++
		}
	}

	// 减少循环与临时变量 分页查询条件放后面
	offsetField := global.Field{
		ColNum:      i,
		ColName:     "offset",
		ColTypeName: "int32",
		ColComment:  "页码",
		Ignore:      true,
	}
	countField := global.Field{
		ColNum:      i + 1,
		ColName:     "count",
		ColTypeName: "int32",
		ColComment:  "每页数量",
		Ignore:      true,
	}
	orderField := global.Field{
		ColNum:      i + 2,
		ColName:     "order_field",
		ColTypeName: "string",
		ColComment:  "排序字段",
		Ignore:      true,
	}
	ascField := global.Field{
		ColNum:      i + 3,
		ColName:     "ascend",
		ColTypeName: "bool",
		ColComment:  "排序方式",
		Ignore:      true,
	}
	queryAllList = append(queryAllList, offsetField)
	queryAllList = append(queryAllList, countField)
	queryAllList = append(queryAllList, orderField)
	queryAllList = append(queryAllList, ascField)

	//表结构详情
	tableInfoMsg := global.Message{
		MsgName:   table.BigHumpTableName + "Info",
		FieldList: infoFieldList,
	}
	//表结构详情 包含ID
	tableMsg := global.Message{
		MsgName:   table.BigHumpTableName,
		FieldList: tableFieldList,
	}

	//新增
	createReqList := []global.Field{infoField}
	cRep := global.Message{
		MsgName:   table.CreateFunc.RequestName,
		FieldList: createReqList,
	}
	returnFieldList2 := []global.Field{returnField, idField2}
	cResp := global.Message{
		MsgName:   table.CreateFunc.ResponseName,
		FieldList: returnFieldList2,
	}

	//读取
	queryAllMsg := global.Message{
		MsgName:   "Query" + table.BigHumpTableName + "All",
		FieldList: queryAllList,
	}
	readReqList := []global.Field{queryField}
	rRep := global.Message{
		MsgName:   table.ReadFunc.RequestName,
		FieldList: readReqList,
	}
	readRespList := []global.Field{returnField, repeatedInfoField, totalField}
	rResp := global.Message{
		MsgName:   table.ReadFunc.ResponseName,
		FieldList: readRespList,
	}

	//修改
	uRep := global.Message{
		MsgName:   table.UpdateFunc.RequestName,
		FieldList: tableFieldList,
	}
	uResp := global.Message{
		MsgName:   table.UpdateFunc.ResponseName,
		FieldList: returnFieldList,
	}

	//删除
	deleteField := global.Field{
		ColNum:      2,
		ColName:     "deleted_by",
		ColTypeName: "int64",
		ColComment:  "删除人",
		Ignore:      true,
	}
	deleteList := []global.Field{idField, deleteField}
	dRep := global.Message{
		MsgName:   table.DeleteFunc.RequestName,
		FieldList: deleteList,
	}
	dResp := global.Message{
		MsgName:   table.DeleteFunc.ResponseName,
		FieldList: returnFieldList,
	}

	msgList = append(msgList, tableInfoMsg) //表结构
	msgList = append(msgList, tableMsg)     //表结构包含ID
	msgList = append(msgList, cRep)         //新增请求
	msgList = append(msgList, cResp)        //新增结果
	msgList = append(msgList, queryAllMsg)  //读取请求全部参数
	msgList = append(msgList, rRep)         //读取请求
	msgList = append(msgList, rResp)        //读取结果
	msgList = append(msgList, uRep)         //修改请求
	msgList = append(msgList, uResp)        //修改结果
	msgList = append(msgList, dRep)         //删除请求
	msgList = append(msgList, dResp)        //删除结果

	return
}
