package model

import (
	"generate-proto/global"
)

type DbTableCols struct {
	ColName    string `json:"colName"`    //行名
	IsNull     string `json:"isNull"`     //YES NO
	DataType   string `json:"dataType"`   //数据类型 varchar
	ColType    string `json:"colType"`    //数据类型 varchar(20)
	ColKey     string `json:"colKey"`     //PRI ""
	ColComment string `json:"colComment"` //注释
}

func (d DbTableCols) GetTableCols(tableName, tableComment string) ([]*DbTableCols, error) {
	var (
		cols []*DbTableCols
	)
	if err := global.CoreDB.
		Raw("SELECT COLUMN_NAME AS col_name,IS_NULLABLE AS is_null,DATA_TYPE AS data_type,COLUMN_TYPE AS col_type,COLUMN_KEY AS col_key,COLUMN_COMMENT AS col_comment FROM information_schema.COLUMNs t WHERE t.`TABLE_SCHEMA`= ? AND `TABLE_NAME` = ?", global.CoreDBName, tableName).
		Scan(&cols).
		Error; err != nil {
		return nil, err
	}

	return cols, nil
}
