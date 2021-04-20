package main

import (
	"generate-proto/global"
	"time"

	"github.com/go-ini/ini"
	"github.com/labstack/gommon/log"
)

type Config struct {
	debugWeb     bool          //web调试模式
	debugDB      bool          //db调试模式
	endpoint     string        //web服务监听地址
	readTimeout  time.Duration //web请求读取超时时间
	writeTimeout time.Duration //web回复写入超时时间
	reqLimit     int           //每秒钟请求上限
	dbType       string        //数据库类型
	dbCoreAddr   string        //数据库地址
	dbCoreName   string        //数据库名称
}

func loadConfig() (conf *Config, err error) {
	var (
		cfg *ini.File
	)

	cfg, err = ini.Load("config.ini")

	if err != nil {
		log.Fatalf("load file hatweb.ini failed: %s", err)
	}

	conf = &Config{}
	conf.debugWeb, err = cfg.Section("debug").Key("web").Bool()
	if err != nil {
		return nil, err
	}
	conf.debugDB, err = cfg.Section("debug").Key("db").Bool()
	if err != nil {
		return nil, err
	}
	conf.endpoint = cfg.Section("http").Key("endpoint").String()
	conf.readTimeout, err = cfg.Section("http").Key("readTimeout").Duration()
	if err != nil {
		return nil, err
	}
	conf.writeTimeout, err = cfg.Section("http").Key("writeTimeout").Duration()
	if err != nil {
		return nil, err
	}
	conf.reqLimit, err = cfg.Section("http").Key("reqLimitPerSecond").Int()
	if err != nil {
		return nil, err
	}
	conf.dbType = cfg.Section("db").Key("type").String()
	conf.dbCoreAddr = cfg.Section("db").Key("core").String()
	conf.dbCoreName = cfg.Section("db").Key("coreName").String()
	return
}

func (c *Config) apply() bool {
	// 调整http服务日志模式，输出无法调整（中间件不能动态调整）
	if httpSvr != nil {
		httpSvr.SetLogMode(c.debugWeb)
	}

	// 调整orm日志输出模式
	if c.debugDB {
		if global.CoreDB != nil {
			global.CoreDB.LogMode(true)
		}
	} else {
		if global.CoreDB != nil {
			global.CoreDB.LogMode(false)
		}
	}

	log.Infof("applied configuration...")
	log.Infof("web debug mode: %v", c.debugWeb)
	log.Infof("db debug mode: %v", c.debugDB)
	log.Infof("start listening: %s", c.endpoint)
	log.Infof("read timeout: %s", c.readTimeout)
	log.Infof("write timeout: %s", c.writeTimeout)
	log.Infof("db type: %s", c.dbType)
	log.Infof("db(core) address: %s", c.dbCoreAddr)
	return true
}
