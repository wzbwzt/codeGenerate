package model

import (
	"generate-proto/global"
	"time"
)

type DbTableList struct {
	Total int        `json:"total"`
	List  []*DbTable `json:"list"`
}

type DbTable struct {
	TableName    string    `json:"tableName"`
	TableComment string    `json:"tableComment"`
	CreateTime   time.Time `json:"createTime"`
}

func (d DbTable) GetTableList() (*DbTableList, error) {
	var infoList []*DbTable
	if err := global.CoreDB.
		Raw("SELECT t.TABLE_NAME AS table_name,t.TABLE_COMMENT AS table_comment,t.CREATE_TIME AS create_time FROM information_schema.TABLES t WHERE t.`TABLE_SCHEMA`= ?", global.CoreDBName).
		Scan(&infoList).
		Error; err != nil {
		return nil, err
	}
	result := &DbTableList{Total: len(infoList), List: infoList}
	return result, nil
}

func (d DbTable) GetTableComment(tableName string) string {
	var info *DbTable
	if err := global.CoreDB.
		Raw("SELECT TABLE_NAME AS table_name,TABLE_COMMENT AS table_comment,CREATE_TIME AS create_time FROM information_schema.TABLES WHERE TABLE_SCHEMA= ? and TABLE_NAME = ?", global.CoreDBName, tableName).
		Scan(&info).
		Error; err != nil {
		return ""
	}

	return info.TableComment
}
