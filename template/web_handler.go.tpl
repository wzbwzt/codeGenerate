package {{.ModelName}}

{{$First := .First}}
{{$BigHumpTableName := .BigHumpTableName}}
import (
    "context"
    "fmt"
    "net/http"
    "time"

    "langmy.com/hatweb/model/proj"
    {{.ModelName}} "langmy.com/hatweb/proto/{{.ModelName}}"

    "github.com/gin-gonic/gin"
    "github.com/micro/go-micro/v2/logger"
    "langmy.com/hatweb/global"
    "langmy.com/hatweb/proto"
)

//{{.TableComment}}详情
type {{.BigHumpTableName}}Info struct {
    {{range .ColList }}{{if eq .Ignore false}} {{.BigHumpColName}}   {{.ColTypeName}} `json:"{{.LittleHumpColName}}"`   //{{.ColComment}}{{end}}
    {{ end }}
}

type Add{{.BigHumpTableName}}Param struct {
    {{.BigHumpTableName}}Info
}

type {{.UpdateFunc.FuncName}}Param struct {
    Id     int64 `json:"id"`
    {{.BigHumpTableName}}Info
}

type {{.BigHumpTableName}}ResultInfo struct {
    Id int64 `json:"id"`
    {{.BigHumpTableName}}Info
}

type {{.BigHumpTableName}}ListParam struct {
    proj.CommonSearchParam
    Name string `json:"name"`
}

type {{.BigHumpTableName}}ListResult struct {
    Total int                    `json:"total"`
    List  []{{.BigHumpTableName}}ResultInfo `json:"list"`
}

//请求参数转protobuf model
func ({{.First}} {{.BigHumpTableName}}Info) ToProtobufModel() (result *{{.ModelName}}.{{.BigHumpTableName}}Info) {

    result = &{{.ModelName}}.{{.BigHumpTableName}}Info{
        {{range .ColList }}{{if eq .Ignore false}}{{.BigHumpColName}}:  {{$First}}.{{.BigHumpColName}},{{end}}
        {{ end }}
    }
    return
}

//protobuf model 转返回参数
func To{{.BigHumpTableName}}ResultInfo({{.First}} *{{.ModelName}}.{{.BigHumpTableName}}) (result {{.BigHumpTableName}}ResultInfo) {

    result = {{.BigHumpTableName}}ResultInfo{
        Id: {{.First}}.Id,
        {{.BigHumpTableName}}Info: {{.BigHumpTableName}}Info{
            {{range .ColList }}{{if eq .Ignore false}} {{.BigHumpColName}}:  {{$First}}.{{$BigHumpTableName}}Info.{{.BigHumpColName}},{{end}}
            {{ end }}
        },
    }
    return
}

//TODO 请求参数检测
func ({{.First}} {{.BigHumpTableName}}Info) Check() error {
    {{range .ColList }}{{if eq .Base false}}    //if {{$First}}.{{.BigHumpColName}} == nil || len(*{{$First}}.{{.BigHumpColName}}) == 0 {
        //    return fmt.Errorf("{{.ColComment}}不能为空!")
        //}{{end}}
    {{ end }}
    return nil
}



//-------------------------handler分界线--------------------------


//新增{{.TableComment}}
func Add{{.BigHumpTableName}}Handler(c *gin.Context) {
    param := &Add{{.BigHumpTableName}}Param{}
    resp := &global.Response{}
    defer c.JSON(http.StatusOK, resp)

    err := c.ShouldBindJSON(param)
    if err != nil {
        logger.Errorf("illegal body: %s", err)
        resp.Code = global.ErrCodeParamInvalid
        resp.Msg = "参数无效"
        return
    }

    if err = param.{{.BigHumpTableName}}Info.Check(); err != nil {
        resp.Code = global.ErrCodeInternal
        resp.Msg = err.Error()
        return
    }

    {{.LittleHumpTableName}}Info := param.{{.BigHumpTableName}}Info.ToProtobufModel()
    req := &{{.ModelName}}.{{.CreateFunc.RequestName}}{
        {{.BigHumpTableName}}Info: {{.LittleHumpTableName}}Info,
    }

    ctx, cancel := context.WithTimeout(context.Background(), time.Second*5)
    defer cancel()
    rsp, err := proto.{{.ServiceName}}.{{.CreateFunc.FuncName}}(ctx, req)
    if err != nil {
        logger.Error("新增{{.TableComment}}处理失败:", err)
        resp.Code = global.ErrCodeInternal
        resp.Msg = "新增{{.TableComment}}失败"
        return
    }
    ret := rsp.Ret
    if ret != nil && ret.Code != 0 {
        logger.Error(ret.Reason)
        resp.Code = global.ErrCodeInternal
        resp.Msg = ret.Reason
        return
    }
    resp.Code = global.ErrCodeSuccess
    resp.Msg = "success"
    return
}

//修改{{.TableComment}}
func {{.UpdateFunc.FuncName}}Handler(c *gin.Context) {
    param := &{{.UpdateFunc.FuncName}}Param{}
    resp := &global.Response{}
    defer c.JSON(http.StatusOK, resp)

    err := c.ShouldBindJSON(param)
    if err != nil {
        logger.Errorf("illegal body: %s", err)
        resp.Code = global.ErrCodeParamInvalid
        resp.Msg = "参数无效"
        return
    }

    if err = param.{{.BigHumpTableName}}Info.Check(); err != nil {
        resp.Code = global.ErrCodeInternal
        resp.Msg = err.Error()
        return
    }

    {{.LittleHumpTableName}}Info := param.{{.BigHumpTableName}}Info.ToProtobufModel()
        req := &{{.ModelName}}.{{.UpdateFunc.RequestName}}{
        Id:             param.Id,
        {{.BigHumpTableName}}Info: {{.LittleHumpTableName}}Info,
    }

    ctx, cancel := context.WithTimeout(context.Background(), time.Second*5)
    defer cancel()
    rsp, err := proto.{{.ServiceName}}.{{.UpdateFunc.FuncName}}(ctx, req)
    if err != nil {
        logger.Error("修改{{.TableComment}}处理失败:", err)
        resp.Code = global.ErrCodeInternal
        resp.Msg = "修改{{.TableComment}}失败"
        return
    }
    ret := rsp.Ret
    if ret != nil && ret.Code != 0 {
        logger.Error(ret.Reason)
        resp.Code = global.ErrCodeInternal
        resp.Msg = ret.Reason
        return
    }
    resp.Code = global.ErrCodeSuccess
    resp.Msg = "success"
    return
}

//删除{{.TableComment}}
func {{.DeleteFunc.FuncName}}Handler(c *gin.Context) {
    type postData struct {
        Id int64 `json:"id"`
    }
    param := &postData{}
    resp := &global.Response{}
    defer c.JSON(http.StatusOK, resp)

    err := c.ShouldBindJSON(param)
    if err != nil {
        logger.Errorf("illegal body: %s", err)
        resp.Code = global.ErrCodeParamInvalid
        resp.Msg = "参数无效"
        return
    }

    req := &{{.ModelName}}.{{.DeleteFunc.RequestName}}{
        Id: param.Id,
    }

    ctx, cancel := context.WithTimeout(context.Background(), time.Second*5)
    defer cancel()
    rsp, err := proto.{{.ServiceName}}.{{.DeleteFunc.FuncName}}(ctx, req)
    if err != nil {
        logger.Error("删除{{.TableComment}}处理失败:", err)
        resp.Code = global.ErrCodeInternal
        resp.Msg = "删除{{.TableComment}}失败"
        return
    }
    ret := rsp.Ret
    if ret != nil && ret.Code != 0 {
        logger.Error(ret.Reason)
        resp.Code = global.ErrCodeInternal
        resp.Msg = ret.Reason
        return
    }
    resp.Code = global.ErrCodeSuccess
    resp.Msg = "success"
    return
}

//根据id查询{{.TableComment}}详情
func Query{{.BigHumpTableName}}InfoHandler(c *gin.Context) {
    type postData struct {
        Id int64 `json:"id"`
    }
    param := &postData{}
    resp := &global.Response{}
    defer c.JSON(http.StatusOK, resp)

    err := c.ShouldBindJSON(param)
    if err != nil {
        logger.Errorf("illegal body: %s", err)
        resp.Code = global.ErrCodeParamInvalid
        resp.Msg = "参数无效"
        return
    }

    req := &{{.ModelName}}.{{.ReadFunc.RequestName}}{
            Query: &{{.ModelName}}.{{.ReadFunc.RequestName}}_ById{
                ById: &{{.ModelName}}.QueryByID{
                Id: param.Id,
            },
        },
    }

    ctx, cancel := context.WithTimeout(context.Background(), time.Second*5)
    defer cancel()
    rsp, err := proto.{{.ServiceName}}.{{.ReadFunc.FuncName}}(ctx, req)
    if err != nil {
        logger.Error("查询{{.TableComment}}详情处理失败:", err)
        resp.Code = global.ErrCodeInternal
        resp.Msg = "查询{{.TableComment}}详情失败"
        return
    }
    ret := rsp.Ret
    if ret != nil && ret.Code != 0 {
        logger.Error(ret.Reason)
        resp.Code = global.ErrCodeInternal
        resp.Msg = ret.Reason
        return
    }
    {{.LittleHumpTableName}}s := rsp.{{.BigHumpTableName}}
    if len({{.LittleHumpTableName}}s) > 0 {
        {{.LittleHumpTableName}}Info := To{{.BigHumpTableName}}ResultInfo({{.LittleHumpTableName}}s[0])
        resp.Data = {{.LittleHumpTableName}}Info
    }
    resp.Code = global.ErrCodeSuccess
    resp.Msg = "success"
    return
}

//查询{{.TableComment}}列表
func Query{{.BigHumpTableName}}ListHandler(c *gin.Context) {
    param := &{{.BigHumpTableName}}ListParam{}
    resp := &global.Response{}
    defer c.JSON(http.StatusOK, resp)

    err := c.ShouldBindJSON(param)
    if err != nil {
    logger.Errorf("illegal body: %s", err)
        resp.Code = global.ErrCodeParamInvalid
        resp.Msg = "参数无效"
        return
    }

    req := &{{.ModelName}}.{{.ReadFunc.RequestName}}{
        Query: &{{.ModelName}}.{{.ReadFunc.RequestName}}_All{
            All: &{{.ModelName}}.Query{{.BigHumpTableName}}All{
                Offset: func() int32 {
                    if param.Paging.Current == 0 {
                        param.Paging.Current = 1
                    }
                    return int32(param.Paging.Current-1) * int32(param.Paging.PageSize)
                }(),
                Count:      int32(param.Paging.PageSize),
                OrderField: param.Sorter.Field,
                Ascend:     param.Sorter.Order == proj.SearchOrderDesc,
            },
        },
    }

    ctx, cancel := context.WithTimeout(context.Background(), time.Second*5)
    defer cancel()
    rsp, err := proto.{{.ServiceName}}.{{.ReadFunc.FuncName}}(ctx, req)
    if err != nil {
        logger.Error("查询{{.TableComment}}列表处理失败:", err)
        resp.Code = global.ErrCodeInternal
        resp.Msg = "查询{{.TableComment}}列表失败"
        return
    }
    ret := rsp.Ret
    total := rsp.Total
    if ret != nil && ret.Code != 0 {
        logger.Error(ret.Reason)
        resp.Code = global.ErrCodeInternal
        resp.Msg = ret.Reason
        return
    }
    {{.LittleHumpTableName}}s := rsp.{{.BigHumpTableName}}
    {{.LittleHumpTableName}}List := make([]{{.BigHumpTableName}}ResultInfo, 0)
    for _, v := range {{.LittleHumpTableName}}s {
        {{.LittleHumpTableName}}Info := To{{.BigHumpTableName}}ResultInfo(v)
        {{.LittleHumpTableName}}List = append({{.LittleHumpTableName}}List, {{.LittleHumpTableName}}Info)
    }
    resp.Data = {{.BigHumpTableName}}ListResult{
        Total: int(total),
        List:  {{.LittleHumpTableName}}List,
    }
    resp.Code = global.ErrCodeSuccess
    resp.Msg = "success"
    return
}
