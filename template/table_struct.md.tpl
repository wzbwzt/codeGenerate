{{ range $key, $value := .TableMap}}
表名: {{ $value.TableName }}
描述: {{ $value.TableComment }}
表结构：

| 字段名            | 字段类型 | 可为空 | 约束 | 备注                             |
|-------------------|--:-------|--------|--:---|----------------------------------|
{{range $value.ColList }}| {{.ColName}} | {{.ColTypeNameGo}}   | {{if eq .ColIsNull "YES"}}是{{else}}否 {{end}}| {{.ColType}} | {{.ColComment}}                             |
{{ end }}

{{end}}