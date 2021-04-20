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

type {{.BigHumpTableName}}Service struct {
    S micro.Service
    *model.{{.BigHumpTableName}}
}

func (s *{{.BigHumpTableName}}Service) Create(ctx context.Context, req *{{.ModelName}}.{{.CreateFunc.RequestName}}, rsp *{{.ModelName}}.{{.CreateFunc.ResponseName}}) error {
    logger.Debug("Received {{.BigHumpTableName}}Service.Create request")
    if err := s.New(req); err != nil {
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

func (s *{{.BigHumpTableName}}Service) Update(ctx context.Context, req *{{.ModelName}}.{{.UpdateFunc.RequestName}}, rsp *{{.ModelName}}.{{.UpdateFunc.ResponseName}}) error {
    logger.Debug("Received {{.BigHumpTableName}}Service.Update request")
    if err := s.Modify(req); err != nil {
        if err == global.ErrRuleNameExist {
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

func (s *{{.BigHumpTableName}}Service) Delete(ctx context.Context, req *{{.ModelName}}.{{.DeleteFunc.RequestName}}, rsp *{{.ModelName}}.{{.DeleteFunc.ResponseName}}) error {
    logger.Debug("Received {{.BigHumpTableName}}Service.Delete request")
    if err := s.Remove(req); err != nil {
        return errors.InternalServerError(s.S.Name(), err.Error())
    }
    return nil
}

func (s *{{.BigHumpTableName}}Service) Read(ctx context.Context, req *{{.ModelName}}.Read{{.BigHumpTableName}}Request, rsp *{{.ModelName}}.Read{{.BigHumpTableName}}Response) error {
    logger.Debug("Received {{.BigHumpTableName}}Service.Read request")
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
