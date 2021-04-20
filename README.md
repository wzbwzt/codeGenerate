### 项目说明
- 提供了代码生成器
- 支持MySQL数据库，PostgreSQL等其他待添加


### 项目结构
```
generate-code
├─global                公共参数
│ 
├─handler               接口
│ 
├─middle
│ 
├─model                 sql    
│ 
├─res                   生成目标文件存放位置
│    │     
│    ├─model            微服务model
│    ├─proto            proto文件
│    ├─serviceHandler   微服务handler
│    └─webHandler       web服务handler
│ 
├─static                前端文件    
│ 
├─template              模板文件
│ 
├─config,inni           配置文件    
│ 
├─res.zip               打包好的生成代码    

```

### 使用说明
1. 修改项目下`config.ini`的数据库连接和表名
2. `go mod tidy`出现下包报错可能使用模板文件引用的，可以忽略
3. 打开浏览器进入 `http://localhost:9000`
4. 筛选选中需要生成的表，配置对应参数，确认生成
5. 生成后使用`res.zip`文件或者使用 `res/`文件夹的生成文件
```ini
[debug]
web = true
db = true

[http]
endpoint = 0.0.0.0:9000
writeTimeout = 5s
readTimeout = 5s
reqLimitPerSecond = 1000


;只需要修改core与coreName
[db]
type = mysql
core = root:nmx@tcp(192.168.0.181:3306)/park_config?interpolateParams=true&parseTime=true&loc=Asia%2FShanghai
coreName = park_config
```

### 页面配置
```
模块名称：pkcenter    //微服务模块名称
连接数据库：ServiceDB //数据库连接实体名称
忽略表前缀：pkcenter_ //生成的文件名/实体驼峰名称都将忽略前缀
数据转换类型： 
普通              已实现，数据库字段类型转换成go常用类型
go-protobuf      待实现，数据库字段类型转换成go proto buf协议类型
gogo-protobuf    考虑实现，数据库字段类型转换成gogo proto buf协议类型,据说效率比较go proto buf高

服务名类型：
表服务名    生成多个以表命名的服务名称
单服务名    只生成一个服务名称，选中会展示服务名称字段进行修改

表名       选中表名
表注释     修改表注释，生成的对应错误日志/注释/错误返回msg都根据表注释替换
中间表     待实现，一对多关联表
```
