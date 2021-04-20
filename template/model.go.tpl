package model

{{$First := .First}}
import (
    "{{.ModelName}}/global"
    {{.ModelName}} "{{.ModelName}}/proto/{{.ModelName}}"
    "{{.ModelName}}/utils"
    "fmt"
    "github.com/jinzhu/gorm"

    "time"
    "github.com/micro/go-micro/v2/logger"
)

type {{.BigHumpTableName}} struct{
    BaseModel
    {{range .ColList }}{{if eq .Base false}}{{.BigHumpColName}}  {{.ColTypeName}} `gorm:"type:{{.ColType}} comment '{{.ColComment}}'"`  //{{.ColComment}}{{end}}
    {{ end }}
}


func ({{.First}} *{{.BigHumpTableName}}) tableName() string {
    return "{{.TableName}}"
}

func ({{.First}} {{.BigHumpTableName}}) migrate(db *gorm.DB) error {
    return db.Table({{.First}}.tableName()).AutoMigrate(&{{.First}}).Error
}

func ({{.First}} *{{.BigHumpTableName}}) From{{.BigHumpTableName}}(info *{{.ModelName}}.{{.BigHumpTableName}}Info) (result *{{.BigHumpTableName}}) {
    {{range .ColList }}{{if eq .Ignore false}}result.{{.BigHumpColName}} = info.Get{{.BigHumpColName}}(){{end}}
    {{ end }}
    return
}

func ({{.First}} *{{.BigHumpTableName}}) To{{.BigHumpTableName}}() (result *{{.ModelName}}.{{.BigHumpTableName}}) {
    return &{{.ModelName}}.{{.BigHumpTableName}}{
        Id: int64({{.First}}.ID),
        {{.BigHumpTableName}}Info: &{{.ModelName}}.{{.BigHumpTableName}}Info{
        {{range .ColList }}{{if eq .Ignore false}}{{.BigHumpColName}}: {{$First}}.{{.BigHumpColName}},{{end}}
        {{ end }}
        },
    }
}


//新增{{.TableComment}}
func ({{.First}} *{{.BigHumpTableName}}) New(req *{{.ModelName}}.{{.CreateFunc.RequestName}}) (err error) {
    //TODO 唯一性校验

    {{.First}} = {{.First}}.From{{.BigHumpTableName}}(req.{{.BigHumpTableName}}Info)

    //{{.First}}.CreatedBy = req.CreatedBy
    if err = global.{{.ConnectDb}}.Table({{.First}}.tableName()).Create({{.First}}).Error; err != nil {
        logger.Error("新增{{.TableComment}}错误:", err)
        return err
    }
    return
}

//修改{{.TableComment}}
func ({{.First}} *{{.BigHumpTableName}}) Modify(req *{{.ModelName}}.{{.UpdateFunc.RequestName}}) (err error) {
    //TODO 唯一性校验

    {{.First}} = {{.First}}.From{{.BigHumpTableName}}(req.{{.BigHumpTableName}}Info)

    //{{.First}}.UpdatedBy = utils.GetFromInt64Value(req.UpdatedBy)
    {{.First}}.ID = uint(req.Id)
    if err = global.{{.ConnectDb}}.Table({{.First}}.tableName()).
        Where("id = ?", req.Id).Update({{.First}}).Error; err != nil {
        logger.Error("修改{{.TableComment}}错误:", err)
        return err
    }
    return
}

//删除{{.TableComment}}
func ({{.First}} *{{.BigHumpTableName}}) Remove(req *{{.ModelName}}.{{.DeleteFunc.RequestName}}) (err error) {
    now := time.Now()
    {{.First}} = &{{.BigHumpTableName}}{}
    {{.First}}.DeletedAt = &now
    //{{.First}}.DeletedBy = utils.GetFromInt64Value(req.DeletedBy)
    if err = global.{{.ConnectDb}}.Table({{.First}}.tableName()).
        Where("id = ?", req.Id).Update({{.First}}).Error; err != nil {
        return err
    }
    return
}

//根据id查询
func ({{.First}} *{{.BigHumpTableName}}) QueryByID(q *{{.ModelName}}.QueryByID, cb QueryFunc) error {
    db := global.{{.ConnectDb}}.Table({{.First}}.tableName())
    db = db.Where("id = ?", q.GetId())

    return query(db, cb, []{{.BigHumpTableName}}{}, 0, 1)
}

//查询{{.TableComment}}列表
func ({{.First}} *{{.BigHumpTableName}}) QueryAll(q *{{.ModelName}}.Query{{.BigHumpTableName}}All, cb QueryFunc, projId int64) error {
    tx := global.{{.ConnectDb}}.Begin()
    defer tx.Commit()

    db := tx.Table({{.First}}.tableName())
    db = db.Where("proj_id = ?", projId)

    //TODO 查询条件添加修改
    {{range .ColList }}{{if eq .Ignore false}}//if q.Get{{.BigHumpColName}}() != nil {
    //    db = db.Where("{{.ColName}} like ?", genValLikePattern(q.Get{{.BigHumpColName}}())) //{{.ColType}}
    //}{{end}}
    {{ end }}

    if len(q.GetOrderField()) > 0 {
        if utils.HasField({{.First}}, q.GetOrderField()) {
            if q.GetAscend() {
                db = db.Order(fmt.Sprintf("%s asc", gorm.ToColumnName(q.GetOrderField())))
            } else {
                db = db.Order(fmt.Sprintf("%s desc", gorm.ToColumnName(q.GetOrderField())))
            }
        } else {
            logger.Warnf("非法排序字段：%s", q.GetOrderField())
        }
    } else {
        db = db.Order("created_at desc")
    }

    return query(db, cb, []{{.BigHumpTableName}}{}, q.GetOffset(), q.GetCount())
}
