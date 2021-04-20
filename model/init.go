package model

import (
	"generate-proto/global"
	"github.com/jinzhu/gorm"
	_ "github.com/jinzhu/gorm/dialects/mysql"
)

func Init(dbType, dbAddr string) (err error) {
	global.CoreDB, err = gorm.Open(dbType, dbAddr)
	if err != nil {
		return err
	}

	return nil
}
