syntax = "proto3";
option go_package = ".;{{.ModelName}}";
package go.micro.service.{{.ModelName}};

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



{{range .ServiceList}}
// {{.ServiceComment}}
service {{.ServiceName}} {
{{range .FuncList }}    rpc {{.FuncName}}({{.RequestName}}) returns ({{.ResponseName}}) {}
{{ end }}
}
{{ end }}

{{range .MsgList }}
message {{ .MsgName }} {
{{range .FieldList }}    {{.ColTypeName}} {{.ColName}}{{if eq .Base false}}={{.ColNum}};{{end}}//{{.ColComment}}
{{ end }}
}
{{ end }}


