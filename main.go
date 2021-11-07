package main

import (
	"generate-proto/global"
	"generate-proto/model"

	"github.com/labstack/gommon/log"
)

var httpSvr *HttpSvr

func main() {
	conf, err := loadConfig()
	if err != nil {
		log.Fatalf("load config failed, %s", err)
	}

	global.CoreDBName = conf.dbCoreName
	// 初始化数据库连接
	err = model.Init(conf.dbType, conf.dbCoreAddr)
	if err != nil {
		log.Fatalf("initialize model failed, %s", err)
	}

	// 应用配置项
	if !conf.apply() {
		log.Fatalf("apply conf failed!")
	}

	httpSvr = NewHttpSvr(conf.endpoint, log.Output(), conf.debugWeb)

	//启动服务
	httpSvr.Run()
}
