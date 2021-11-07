package model

{* {{$First := .First}} *}
{* import (
    "{{.ModelName}}/global"
    {{.ModelName}} "{{.ModelName}}/proto/{{.ModelName}}"
    "{{.ModelName}}/utils"
    "fmt"
    "gorm.io/gorm"

    "time"
    "github.com/micro/go-micro/v2/logger"
) *}

{* type {{.BigHumpTableName}} struct{
    gorm.Model
    {{range .ColList }}{{if eq .Base false}}{{.BigHumpColName}}  {{.ColTypeNameGo}} `gorm:"type:{{.ColType}};not null; comment:{{.ColComment}}"`  //{{.ColComment}}{{end}}
    {{ end }}
} *}


{* func ({{.First}} {{.BigHumpTableName}}) tableName() string {
    return "{{.TableName}}"
} *}


{* func ({{.First}} *{{.BigHumpTableName}}) From{{.BigHumpTableName}}(info *{{.ModelName}}.{{.BigHumpTableName}}Info) (result *{{.BigHumpTableName}}) {
    // BaseModel 字段在New Modify Delete添加
    result = &{{.BigHumpTableName}}{
        ID: int64(info.ID),
        {{range .ColList }}
            {{if eq .Base false}}{{.BigHumpColName}}: info.{{.BigHumpColName}},{{end}}
        {{ end }}
    }
    return
} *}

{* func ({{.First}} *{{.BigHumpTableName}}) To{{.BigHumpTableName}}() (result *{{.ModelName}}.{{.BigHumpTableName}}) {
    // Todo 除了基础字段的时间类型 其他时间字段需要自行加上.Format(time.RFC3339) 没有可以忽略
    result = &{{.ModelName}}.{{.BigHumpTableName}}{
        Id: int64({{.First}}.ID),
        {{.BigHumpTableName}}Info: &{{.ModelName}}.{{.BigHumpTableName}}Info{
            //ProjId: utils.CreateInt64Value({{$First}}.ProjId),
            //CreatedAt: utils.CreateStringValue({{$First}}.CreatedAt.Format(time.RFC3339)),
            //UpdatedAt: utils.CreateStringValue({{$First}}.UpdatedAt.Format(time.RFC3339)),
            {{range .ColList }}{{if .Pointer}}{{.BigHumpColName}}: ({{.First}}.{{.BigHumpColName}}),{{end}}
            {{ end }}
        },
    }
    return
} *}


{* func ({{.First}} *{{.BigHumpTableName}}) getByCon(db *gorm.DB) (recs []*{{.BigHumpTableName}}, err error) {
	tx := db.Model({{.BigHumpTableName}}{})
	if {{.First}}.ID != 0 {
		tx = tx.Where("id=?", {{.First}}.ID)
	}
    {{range .ColList }}
        {{if eq .Base false}}
        if {{.First}}.{{.BigHumpColName}} !={{ if eq .ColTypeNameGo int32  }}0{{ else if eq .ColTypeNameGo int64}} 0{{ else if eq .ColTypeNameGo string }} ""{{ end }}  {
            tx = tx.Where("{{.ColName}}=?", {{.First}}.{{.BigHumpColName}})
        }
        {{end}}
    {{ end }}

	if err = tx.Find(&recs).Error; err != nil {
		return
	}
    return
} *}


{*
func ({{.First}} *{{.BigHumpTableName}}) new(db *gorm.DB) error {
    if err := global.{{.ConnectDb}}.Model({{.BigHumpTableName}}{}).Create({{.First}}).Error; err != nil {
		return err
	}
    return nil
}

func ({{.First}} *{{.BigHumpTableName}}) update(db *gorm.DB) error {
	if err := global.{{.ConnectDb}}.Model({{.BigHumpTableName}}{}).
		Where("id=?", {{.First}}.ID).
		Updates({{.First}}).Error; err != nil {
		return err
	}
    return nil
}

func ({{.First}} *{{.BigHumpTableName}}) del(db *gorm.DB) error {
	if err := global.{{.ConnectDb}}.Model({{.BigHumpTableName}}{}).
		Where("id=?", {{.First}}.ID).
		Delete(&{{.BigHumpTableName}}{}).Error; err != nil {
		return err
	}
}

func ({{.First}} *{{.BigHumpTableName}}) New() error {
	err := global.{{.ConnectDb}}.Transaction(func(tx *gorm.DB) (err error) {
		err = {{.First}}.new(tx)
		return
	})
	if err != nil {
		return err
	}
	return nil
}

func ({{.First}} *{{.BigHumpTableName}}) Update() error {
	err := global.{{.BigHumpTableName}}.Transaction(func(tx *gorm.DB) (err error) {
		//检查是否存在
		con := {{.BigHumpTableName}}{Model: gorm.Model{ID: {{.First}}.ID}}
		olds, err := con.getByCon(tx)
		if err != nil {
			return
		}
		if len(olds) == 0 {
			return global.NewError(int32({{.ModelName}}.ErrCode_INVALID_PARAM), "记录不存在")
		}


		err = {{.First}}.update(tx)
		return
	})
	if err != nil {
		return err
	}
	return nil
}

func ({{.First}} *{{.BigHumpTableName}}) Remove() error {
	err := global.{{.BigHumpTableName}}.Transaction(func(tx *gorm.DB) (err error) {
		//检查是否存在
		con := {{.BigHumpTableName}}{Model: gorm.Model{ID: {{.First}}.ID}}
		olds, err := con.getByCon(tx)
		if err != nil {
			return
		}
		if len(olds) == 0 {
			return global.NewError(int32({{.ModelName}}.ErrCode_INVALID_PARAM), "记录不存在")
		}


		err = {{.First}}.del(tx)
		return
	})
	if err != nil {
		return err
	}
	return nil
}

func ({{.First}} *{{.BigHumpTableName}})QueryByID(query *{{.ModelName}}.QueryByID) (
    recs []*{{.BigHumpTableName}}, err error) {
	db := global.{{.ConnectDb}}

    //检查是否存在
    con := {{.BigHumpTableName}}{Model: gorm.Model{ID: {{.First}}.ID}}
    olds, err := con.getByCon(tx)
    if err != nil {
        return
    }
    if len(olds) == 0 {
        return global.NewError(int32({{.ModelName}}.ErrCode_INVALID_PARAM), "记录不存在")
    }

	recs = append(recs, olds[0])
	return
}
 *}

{* func ({{.First}} *{{.BigHumpTableName}})QueryByCon(query *{{.ModelName}}.Query{{.BigHumpTableName}}RequestQueryByCon,queryparam *{{.ModelName}}.QueryCommonParam) (
    total int64,recs []*{{.BigHumpTableName}}, err error) {
	db := global.{{.ConnectDb}}
	tx := global.{{.ConnectDb}}.Model({{.BigHumpTableName}}{})
	{{.First}} = {{.First}}.From{{.BigHumpTableName}}(query.GetInfo())

     {{range .ColList }}
        {{if eq .Base false}}
        if {{.First}}.{{.BigHumpColName}} !={{ if eq .ColTypeNameGo int32  }}0{{ else if eq .ColTypeNameGo int64}} 0{{ else if eq .ColTypeNameGo string }} ""{{ end }}  {
            tx = tx.Where("{{.ColName}}=?", {{.First}}.{{.BigHumpColName}})
        }
        {{end}}
    {{ end }} 



	if err = tx.Count(&total).Error; err != nil {
		return
	}

	if HasField({{.BigHumpTableName}}{}, queryparam.GetSort().GetField()) {
		if queryparam.GetSort().GetAsc() == int32(ASC) {
			tx = tx.Order(genColumnName(queryparam.GetSort().Field) + " asc")
		} else {
			tx = tx.Order(genColumnName(queryparam.GetSort().Field) + " desc")
		}
	} else {
		logger.Infof("忽略无效的排序字段(%s)", queryparam.GetSort().GetField())
	}

	if err = tx.Offset(int(queryparam.GetOffset())).
		Limit(int(queryparam.GetCount())).
		Find(&recs).Error; err != nil {
		return
	}

	return
}
 *}
