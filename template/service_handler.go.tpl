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
    {{.FuncName }}:=h.From{{.FuncName}}(req.GetInfo())
    if err := {{.FuncName}}.New(); err != nil {
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
    {{.FuncName }}:=h.From{{.FuncName}}(req.GetInfo())
    if err := {{.FuncName}}.Update(); err != nil {
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
	{{.FuncName}} := model.{{.FuncName}}{Model: gorm.Model{ID: uint(req.GetId())}}
	if err := {{.FuncName}}.Del(); err != nil {
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
		recs  []*model.{{.FuncName}}
	)

	switch req.GetQuery().(type) {
	case *{{.ModelName}}.Read{{.BigHumpTableName}}Request_All:
		q := req.GetQuery().(*{{.ModelName}}.Read{{.BigHumpTableName}}Request_All).ByCon
		total, recs, err = h.QueryByCon(q, req.GetQueryParam())
	case *{{.ModelName}}.Read{{.BigHumpTableName}}Request_ById:
		q := req.GetQuery().(*{{.ModelName}}.Read{{BigHumpTableName}}Request_ById).ById
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

    //old
    cb := func(total int32, rs interface{}) error {
    rsp.Total = total
    if rs != nil {
        {{.LittleHumpTableName}}s := make([]*{{.ModelName}}.{{.BigHumpTableName}}, 0)
        for _, v := range rs.([]model.{{.BigHumpTableName}}) {
            {{.LittleHumpTableName}}s = append({{.LittleHumpTableName}}s, v.To{{.BigHumpTableName}}())
        }
        rsp.{{.BigHumpTableName}} = {{.LittleHumpTableName}}s
    }
    return nil
    }
    switch req.Query.(type) {
        case *{{.ModelName}}.Read{{.BigHumpTableName}}Request_All:
            q := req.Query.(*{{.ModelName}}.Read{{.BigHumpTableName}}Request_All)
            err := s.QueryAll(q.All, cb, q.All.GetProjId())
            if err != nil {
                return errors.InternalServerError(s.S.Name(), err.Error())
            }
        case *{{.ModelName}}.Read{{.BigHumpTableName}}Request_ById:
            q := req.Query.(*{{.ModelName}}.Read{{.BigHumpTableName}}Request_ById)
            err := s.QueryByID(q.ById, cb)
            if err != nil {
                return errors.InternalServerError(s.S.Name(), err.Error())
            }
    }
    return nil
}
