package handler

import (
	"github.com/gin-gonic/gin"
)

//初始化http句柄
func Init(r *gin.Engine) {
	g := r.Group("/api")
	{
		g.POST("/tableList", TableListHandler)
		g.POST("/tableCols", TableColsHandler)
		g.POST("/generateCode", GenerateCode)
	}
}
