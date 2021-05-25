//serviceHandler util query var修改内容
{{ range $key, $value := .TableMap}}
    //{{$value.LittleHumpTableName}}s           []{{$value.BigHumpTableName}}
{{ end }}

//util query swith修改内容
{{ range $key, $value := .TableMap}}
    //case []{{.BigHumpTableName}}:
    //    if err := db.Model({{$value.BigHumpTableName}}{}).Count(&total).Error; err != nil {
    //      return err
    //    }
    //      queryfunc = func(db *gorm.DB) error {
    //  if err := db.Find(&{{$value.LittleHumpTableName}}s).Error; err != nil {
    //  return err
    //  }
    //  return cb(total, {{$value.LittleHumpTableName}}s)
    //  }
{{ end }}



//webHandler url_verify_web 修改内容
{{ range $key, $value := .TableMap}}
    "/api/v1/自定义/{{$value.LittleHumpTableName}}/add": true,
    "/api/v1/自定义/{{$value.LittleHumpTableName}}/update": true,
    "/api/v1/自定义/{{$value.LittleHumpTableName}}/del": true,
    "/api/v1/自定义/{{$value.LittleHumpTableName}}/list": true,
    "/api/v1/自定义/{{$value.LittleHumpTableName}}/info": true,
{{ end }}
