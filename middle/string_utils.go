package middle

import (
	"strings"
	"unicode"
)

// 忽略前缀
// eg: sys_ sys_user_role   user_role
func IgnorePrefix(prefix, target string) string {
	if prefix != "" {
		return strings.ReplaceAll(target, prefix, "")
	} else {
		return target
	}
}

// 下划线转大驼峰
// eg: table_name TableName
func Case2Camel(target string) string {
	if target != "" {
		target = strings.Replace(target, "_", " ", -1)
		target = strings.Title(target)
		return strings.Replace(target, " ", "", -1)
	} else {
		return target
	}

}

// 首字母小写
// eg: TableName tableName
func LowerFisrt(target string) string {
	for i, v := range target {
		return string(unicode.ToLower(v)) + target[i+1:]
	}
	return ""
}

// 忽略前缀并转驼峰
func IgnorePrefixAnd2Camel(prefix, target string) string {
	return Case2Camel(IgnorePrefix(prefix, target))
}
