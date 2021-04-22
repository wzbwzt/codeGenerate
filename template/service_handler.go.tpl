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
    *model.{{.BigHumpTableName}}
}

func (s *{{.ServiceName}}) {{.CreateFunc.FuncName}}(ctx context.Context, req *{{.ModelName}}.{{.CreateFunc.RequestName}}, rsp *{{.ModelName}}.{{.CreateFunc.ResponseName}}) error {
    logger.Debug("Received {{.ServiceName}}.{{.CreateFunc.RequestName}} request")
    if err := s.New(req); err != nil {
        if err == global.ErrAlreadyExist {
            rsp.Ret = &{{.ModelName}}.CommonReturn{
                Code:   -1,
                Reason: "{{.TableComment}}"+err.Error(),
            }
        return nil
        }
        return errors.InternalServerError(s.S.Name(), err.Error())
    }
    return nil
}

func (s *{{.ServiceName}}) {{.UpdateFunc.FuncName}}(ctx context.Context, req *{{.ModelName}}.{{.UpdateFunc.RequestName}}, rsp *{{.ModelName}}.{{.UpdateFunc.ResponseName}}) error {
    logger.Debug("Received {{.ServiceName}}.{{.UpdateFunc.RequestName}} request")
    if err := s.Modify(req); err != nil {
        if err == global.ErrAlreadyExist {
            rsp.Ret = &{{.ModelName}}.CommonReturn{
                Code:   -1,
                Reason: err.Error(),
        }
        return nil
        }
        return errors.InternalServerError(s.S.Name(), err.Error())
    }
    return nil
}

func (s *{{.ServiceName}}) {{.DeleteFunc.FuncName}}(ctx context.Context, req *{{.ModelName}}.{{.DeleteFunc.RequestName}}, rsp *{{.ModelName}}.{{.DeleteFunc.ResponseName}}) error {
    logger.Debug("Received {{.ServiceName}}.{{.DeleteFunc.RequestName}} request")
    if err := s.Remove(req); err != nil {
        return errors.InternalServerError(s.S.Name(), err.Error())
    }
    return nil
}

func (s *{{.ServiceName}}) {{.ReadFunc.FuncName}}(ctx context.Context, req *{{.ModelName}}.{{.ReadFunc.RequestName}}, rsp *{{.ModelName}}.Read{{.BigHumpTableName}}Response) error {
    logger.Debug("Received {{.ServiceName}}.{{.ReadFunc.RequestName}} request")
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
