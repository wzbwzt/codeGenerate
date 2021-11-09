syntax = "proto3";
option go_package = "proto/{{.ModelName}}";
package go.micro.service.{{.ModelName}};
import "google/protobuf/wrappers.proto";

//{{range .ServiceList}}{{.ServiceName}}   pkcenter.{{.ServiceName}}
//{{end}}

//{{range .ServiceList}}{{.ServiceName}} = pkcenter.New{{.ServiceName}}(PkCenterServiceName, client.DefaultClient)
//{{end}}

//_ = chargerule.RegisterHolidayServiceHandler(service.Server(), new(handler.HolidayService))
//{{range .ServiceList}}_= pkcenter.Register{{.ServiceName}}Handler(service.Server(), new(handler.{{.ServiceName}}))
//{{end}}

//在当前文件位置执行 protoc --micro_out=. --go_out=. {{.ModelName}}.proto
// 返回统一字段
enum ErrCode {
  OK = 0; //成功
  INVALID_PARAM = 1; //参数无效
  NAME_COLLISION = 2; //名称冲突
  NOT_EXIST = 3; //不存在
  IN_USE = 4; //使用中
  INTERNAL = 5; //内部错误
  DATA_WRONG = 6; //数据异常
  USER_NOT_REGISTER = 7; //未注册用户
  AUTHORIZATION_FAIL = 8; //授权失败
  SYSTEM_WRONG = 9; //系统错误
}

message CommonReturn {
  ErrCode code = 1; // 错误码
  string reason = 2; // 详细错误信息
}

// 按ID数字查找目标
message QueryByID {
  int64 id = 1;
}

// 排序
message Sorter {
  string field = 1;
  int32 asc = 2; //1-正序，0-倒叙
}

//查询参数
message QueryCommonParam{
    int32 offset =3;
    int32 count =4;
    Sorter sort=5;
}

//操作员信息
message Operator {
    int64 user_id=1;
    string user_name=2;
    int32 user_type=3;
}



{{range .ServiceList}}
// {{.ServiceComment}}服务
service {{.ServiceName}} {
{{range .FuncList }}    rpc {{.FuncName}}({{.RequestName}}) returns ({{.ResponseName}}) {}
{{ end }}
}
{{ end }}


{{range .MsgList }}
message {{ .MsgName }} {
{{range .FieldList }} {{.ColTypeNameGo}} {{.ColName}}{{if eq .Base false}}={{.ColNum}};{{end}}//{{.ColComment}}
{{ end }}
}
{{ end }}


