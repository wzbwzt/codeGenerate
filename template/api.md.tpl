**简要描述：** 

- 查询{{.TableComment}}列表

**请求URL：** 
- ` http://xx.com/api/v1/自定义/{{.LittleHumpTableName}}/list `
**请求方式：**
- POST 

**参数：** 

|参数名|必选|类型|说明|
|:----    |:---|:----- |-----   |
| pagination   | 是 | String  | 分页信息  {"pageSize":10,"current":1}  |
| sorter       | 是 | String  | 排序信息：1-正序，0-倒叙 {"field":"","order":0} |
{{range .ColList }}{{if eq .Ignore false}}|{{.ColName}}       |{{if eq .ColIsNull "YES"}}是{{else}}否 {{end}}  |{{.ColTypeNameGo}}|{{.ColComment}}   |{{end}}
{{end}}

**响应参数：** 

| 参数 | 类型    | 描述       | 是否必填 | 示例  |
| ---- | ------- | ---------- | -------- | ----- |
| code | Integer | 返回码     | 是      | 10000 |
| msg  | String  | 返回码描述 | 是      |       |
| data | String  | 返回数据   | 是      |       |

|参数名|必选|类型|说明|
|:----    |:---|:----- |-----   |
|id       |是  |string|LED id   |
{{range .ColList }}{{if eq .Ignore false}}|{{.ColName}}       |{{if eq .ColIsNull "YES"}}是{{else}}否 {{end}}  |{{.ColTypeNameGo}}|{{.ColComment}}   |{{end}}
{{end}}

**返回示例**

``` 
  {
    "code": 10000,
    "msg": "success",
    "data": {
		totoal:100,
		list:[{}，{}，...]
	}
  }
```





**简要描述：** 

- 新增{{.TableComment}}

**请求URL：** 
- ` http://xx.com/api/v1/carConfig/自定义/{{.LittleHumpTableName}}/add`
  
**请求方式：**
- POST 

**参数：** 

|参数名|必选|类型|说明|
|:----    |:---|:----- |-----   |
{{range .ColList }}{{if eq .Ignore false}}|{{.ColName}}       |{{if eq .ColIsNull "YES"}}是{{else}}否 {{end}}  |{{.ColTypeNameGo}}|{{.ColComment}}   |{{end}}
{{end}}

 **返回示例**

``` 
  {
    "code": 10000,
    "msg": "新增成功",
    "data": null
  }
```
**错误示例**
```
{
	"code": 40004,
    "msg": "未知错误",
    "data": null
}
```





**简要描述：** 

- 修改{{.TableComment}}

**请求URL：** 
- ` http://xx.com/api/v1/自定义/{{.LittleHumpTableName}}/update`
  
**请求方式：**
- POST 

**参数：** 

|参数名|必选|类型|说明|
|:----    |:---|:----- |-----   |
|id   |是  |string |led id |
{{range .ColList }}{{if eq .Ignore false}}|{{.ColName}}       |{{if eq .ColIsNull "YES"}}是{{else}}否 {{end}}  |{{.ColTypeNameGo}}|{{.ColComment}}   |{{end}}
{{end}}

 **返回示例**

``` 
  {
    "code": 10000,
    "msg": "success",
    "data": null
  }
```
**错误示例**
```
{
	"code": 40004,
    "msg": "未知错误",
    "data": null
}
```





**简要描述：** 

- {{.TableComment}}详情

**请求URL：** 
- ` http://xx.com/api/v1/自定义/{{.LittleHumpTableName}}/info`
  
**请求方式：**
- POST 

**参数：** 

|参数名|必选|类型|说明|
|:----    |:---|:----- |-----   |
|id   |是  |string |led id |

**返回参数：** 

|参数名|必选|类型|说明|
|:----    |:---|:----- |-----   |
|id   |是  |string |led id |
{{range .ColList }}{{if eq .Ignore false}}|{{.ColName}}       |{{if eq .ColIsNull "YES"}}是{{else}}否 {{end}}  |{{.ColTypeNameGo}}|{{.ColComment}}   |{{end}}
{{end}}

 **返回示例**

``` 
  {
    "code": 10000,
    "msg": "success",
    "data": null
  }
```
**错误示例**
```
{
	"code": 40004,
    "msg": "未知错误",
    "data": null
}
```





**简要描述：** 

- 删除{{.TableComment}}

**请求URL：** 
- ` http://xx.com/api/v1/自定义/{{.LittleHumpTableName}}/delete`
  
**请求方式：**
- POST 

**参数：** 

|参数名|必选|类型|说明|
|:----    |:---|:----- |-----   |
|id   |是  |string |led id |

 **返回示例**

``` 
  {
    "code": 10000,
    "msg": "success",
    "data": null
  }
```
**错误示例**
```
{
	"code": 40004,
    "msg": "未知错误",
    "data": null
}
```