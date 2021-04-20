package handler

import (
	"generate-proto/global"
	"generate-proto/model"
	"github.com/gin-gonic/gin"
	"github.com/labstack/gommon/log"
	"net/http"
)

func TableListHandler(c *gin.Context) {
	type queryTableListParam struct {
		global.CommonSearchParam
	}
	param := &model.DbTable{}
	resp := &global.Response{}
	defer c.JSON(http.StatusOK, resp)
	err := c.ShouldBindJSON(param)

	tableList, err := model.DbTable{}.GetTableList()
	if err != nil {
		log.Errorf("road flow list failed: %+v", err)
		resp.Code = global.ErrCodeInternal
		resp.Msg = "internal error"
		return
	}
	resp.Data = tableList
	resp.Code = global.ErrCodeSuccess
	resp.Msg = "success"
	return
}
