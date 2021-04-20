package global

type GenerateBody struct {
	ModelName   string           `json:"modelName"`   //模块名
	ConnectDb   string           `json:"connectDb"`   //数据库连接
	ServiceList []Service        `json:"serviceList"` //服务
	MsgList     []Message        `json:"msgList"`     //消息实体
	TableMap    map[string]Table `json:"tableMap"`    //table转化
}

//proto使用
type Service struct {
	ServiceName    string `json:"serviceName"`    //服务名
	ServiceComment string `json:"serviceComment"` //注释
	FuncList       []Func `json:"funcList"`       //方法
}

//proto使用
type Message struct {
	MsgName   string  `json:"msgName"`   //消息名
	FieldList []Field `json:"fieldList"` //具体字段
}

// model handler webHandler使用
type Table struct {
	ModelName           string  `json:"modelName"`           //模块名 冗余存储
	ServiceName         string  `json:"serviceName"`         //服务名 冗余存储
	ConnectDb           string  `json:"connectDb"`           //连接表名
	TableName           string  `json:"tableName"`           //表原始名称 table_name
	BigHumpTableName    string  `json:"bigHumpTableName"`    //表名称大驼峰 TableName
	LittleHumpTableName string  `json:"littleHumpTableName"` //表名称小驼峰 tableName
	First               string  `json:"first"`               //表名称首字母
	TableComment        string  `json:"tableComment"`        //注释
	CreateFunc          Func    `json:"createFunc"`          //添加方法
	ReadFunc            Func    `json:"readFunc"`            //读取方法
	UpdateFunc          Func    `json:"updateFunc"`          //修改方法
	DeleteFunc          Func    `json:"deleteFunc"`          //删除方法
	ColList             []Field `json:"colList"`             //字段list
}

type Func struct {
	FuncName     string `json:"funcName"`     //方法名
	RequestName  string `json:"requestName"`  //请求
	ResponseName string `json:"responseName"` //响应
}

type Field struct {
	ColNum            int    `json:"colNum"`            //序列
	ColName           string `json:"colName"`           //字段名称 col_name
	BigHumpColName    string `json:"bigHumpColName"`    //字段名称大驼峰 ColName
	LittleHumpColName string `json:"littleHumpColName"` //字段名称小驼峰 colName
	ColType           string `json:"colType"`           //字段类型 varchar(128)
	ColTypeName       string `json:"colTypeName"`       //字段类型
	ColTypeNameBak    string `json:"colTypeNameBak"`    //goproto gogoproto 预留字段
	ColIsNull         string `json:"colIsNull"`         //非空 ""  "*"
	ColComment        string `json:"colComment"`        //注释
	Ignore            bool   `json:"ignore"`            //忽略
	Base              bool   `json:"base"`              //基础通用字段
}

// 生成实体忽略
var IgnoreCol = map[string]bool{
	"id":         true,
	"deleted_at": true,
	"deleted_by": true,
}

// 生成model基础字段忽略
var BaseCol = map[string]bool{
	"id":         true,
	"created_at": true,
	"created_by": true,
	"updated_at": true,
	"updated_by": true,
	"deleted_at": true,
	"deleted_by": true,
}
