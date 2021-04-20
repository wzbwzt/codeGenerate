package main

import (
	"generate-proto/handler"
	"generate-proto/middle"
	"io"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

type HttpSvr struct {
	ep     string
	engine *gin.Engine
}

func NewHttpSvr(endpoint string, logOut io.Writer, debug bool) *HttpSvr {
	// 分配http服务引擎
	e := gin.New()
	svr := &HttpSvr{
		ep:     endpoint,
		engine: e,
	}

	// 初始化日志输出
	gin.DefaultWriter = logOut
	gin.DefaultErrorWriter = logOut
	svr.SetLogMode(debug)

	// 添加中间件
	if debug {
		e.Use(gin.Logger())
	}
	e.Use(gin.Recovery())
	e.Use(cors.New(cors.Config{
		AllowOriginFunc: func(orig string) bool {
			return true
		},
		AllowMethods:     []string{"GET", "POST"},
		AllowHeaders:     []string{"Origin", "Content-Length", "Content-Type"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}))

	e.Use(middle.ServeStatic())

	// 初始化http处理句柄
	handler.Init(e)

	return svr
}

func (s *HttpSvr) SetLogMode(debug bool) {
	gin.DisableConsoleColor()
	if debug {
		gin.SetMode(gin.DebugMode)
	} else {
		gin.DisableConsoleColor()
		gin.SetMode(gin.ReleaseMode)
	}
}

func (s *HttpSvr) Run() {
	s.engine.Run(s.ep)
}
