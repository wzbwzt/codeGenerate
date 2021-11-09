

package handler

import (
    "context"

    "github.com/micro/go-micro/v2"
    "github.com/micro/go-micro/v2/errors"
    "github.com/micro/go-micro/v2/logger"

    "{{.ModelName}}/global"
    "{{.ModelName}}/model"
    {{.ModelName}} "{{.ModelName}}/proto/{{.ModelName}}"
)

type {{.ServiceName}} struct {
    S micro.Service
    model.{{.BigHumpTableName}}
}

func (h *{{.ServiceName}}) {{.CreateFunc.FuncName}}(ctx context.Context, req *{{.ModelName}}.{{.CreateFunc.RequestName}}, rsp *{{.ModelName}}.{{.CreateFunc.ResponseName}}) error {
    logger.Debug("Received {{.ServiceName}}.{{.CreateFunc.RequestName}} request")
    {{.LittleHumpTableName }}:=h.From{{.BigHumpTableName}}(req.GetInfo())
    if err := {{.LittleHumpTableName}}.New(); err != nil {
		log.Error(err)
		if myerr, ok := err.(global.Myerr); ok {
			rsp.Ret = &{{.ModelName}}.CommonReturn{
				Code:   {{.ModelName}}.ErrCode(myerr.Code),
				Reason: myerr.Msg,
			}
			return nil
		}
		return errors.InternalServerError(h.S.Name(), err.Error())
	}
    return nil
}

func (h *{{.ServiceName}}) {{.UpdateFunc.FuncName}}(ctx context.Context, req *{{.ModelName}}.{{.UpdateFunc.RequestName}}, rsp *{{.ModelName}}.{{.UpdateFunc.ResponseName}}) error {
    logger.Debug("Received {{.ServiceName}}.{{.UpdateFunc.RequestName}} request")
    {{.LittleHumpTableName }}:=h.From{{.BigHumpTableName}}(req.GetInfo())
    if err := {{.LittleHumpTableName}}.Update(); err != nil {
		log.Error(err)
		if myerr, ok := err.(global.Myerr); ok {
			rsp.Ret = &{{.ModelName}}.CommonReturn{
				Code:   {{.ModelName}}.ErrCode(myerr.Code),
				Reason: myerr.Msg,
			}
			return nil
		}
		return errors.InternalServerError(h.S.Name(), err.Error())
	}
    return nil
}

func (h *{{.ServiceName}}) {{.DeleteFunc.FuncName}}(ctx context.Context, req *{{.ModelName}}.{{.DeleteFunc.RequestName}}, rsp *{{.ModelName}}.{{.DeleteFunc.ResponseName}}) error {
    logger.Debug("Received {{.ServiceName}}.{{.DeleteFunc.RequestName}} request")
	{{.LittleHumpTableName}} := model.{{.BigHumpTableName}}{Model: gorm.Model{ID: uint(req.GetId())}}
	if err := {{.LittleHumpTableName}}.Remove(); err != nil {
		log.Error(err)
		if myerr, ok := err.(global.Myerr); ok {
			rsp.Ret = &{{.ModelName}}.CommonReturn{
				Code:   {{.ModelName}}.ErrCode(myerr.Code),
				Reason: myerr.Msg,
			}
			return nil
		}
		return errors.InternalServerError(h.S.Name(), err.Error())
	}
    return nil
}

func (h *{{.ServiceName}}) {{.ReadFunc.FuncName}}(ctx context.Context, req *{{.ModelName}}.{{.ReadFunc.RequestName}}, rsp *{{.ModelName}}.Read{{.BigHumpTableName}}Response) error {
    logger.Debug("Received {{.ServiceName}}.{{.ReadFunc.RequestName}} request")
	var (
		err   error
		total int64
		recs  []*model.{{.BigHumpTableName}}
	)

	switch req.GetQuery().(type) {
	case *{{.ModelName}}.Read{{.BigHumpTableName}}Request_All:
		q := req.GetQuery().(*{{.ModelName}}.Read{{.BigHumpTableName}}Request_All).All
		total, recs, err = h.QueryByCon(q)
	case *{{.ModelName}}.Read{{.BigHumpTableName}}Request_ById:
		q := req.GetQuery().(*{{.ModelName}}.Read{{.BigHumpTableName}}Request_ById).ById
		recs, err = h.QueryByID(q)
	}

	if err != nil {
		log.Error(err)
		if myerr, ok := err.(global.Myerr); ok {
			rsp.Ret = &{{.ModelName}}.CommonReturn{
				Code:   {{.ModelName}}.ErrCode(myerr.Code),
				Reason: myerr.Msg,
			}
			return nil
		}
		return errors.InternalServerError(h.S.Name(), err.Error())
	}
	rsp.Total = int32(total)
	for _, v := range recs {
		rsp.List = append(rsp.List, v.To{{.BigHumpTableName}}())
	}
	return nil
}
