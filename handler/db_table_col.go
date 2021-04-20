package handler

import (
	"generate-proto/global"
	"generate-proto/model"
	"github.com/gin-gonic/gin"
	"github.com/labstack/gommon/log"
	"net/http"
)

func TableColsHandler(c *gin.Context) {
	type queryTableListParam struct {
		global.CommonSearchParam
		TableName    string `json:"tableName"`
		TableComment string `json:"tableComment"`
	}
	param := &queryTableListParam{}
	resp := &global.Response{}
	defer c.JSON(http.StatusOK, resp)
	err := c.ShouldBindJSON(param)

	tableCols, err := model.DbTableCols{}.GetTableCols(param.TableName, param.TableComment)
	if err != nil {
		log.Errorf("road flow list failed: %+v", err)
		resp.Code = global.ErrCodeInternal
		resp.Msg = "internal error"
		return
	}
	resp.Data = tableCols
	resp.Code = global.ErrCodeSuccess
	resp.Msg = "success"
	return
}
