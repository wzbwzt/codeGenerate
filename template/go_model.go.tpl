package model

{{$First := .First}}
import (
    "{{.ModelName}}/global"
    {{.ModelName}} "{{.ModelName}}/proto/{{.ModelName}}"
    "{{.ModelName}}/utils"
    "fmt"
    "gorm.io/gorm"

    "time"
    "github.com/micro/go-micro/v2/logger"
) 

type {{.BigHumpTableName}} struct{
    gorm.Model
    {{range .ColList }}{{if eq .Base false}}{{.BigHumpColName}}  {{.ColTypeNameGo}} `gorm:"type:{{.ColType}};not null; comment:{{.ColComment}}"`  //{{.ColComment}}{{end}}
    {{ end }}
}



func ({{.First}} {{.BigHumpTableName}}) From{{.BigHumpTableName}}(info *{{.ModelName}}.{{.BigHumpTableName}}) (result *{{.BigHumpTableName}}) {
	if info == nil {
		return
	}
    result = &{{.BigHumpTableName}}{
	Model: gorm.Model{ID: uint(info.GetId())},
        {{range .ColList }}
            {{if eq .Base false}}{{.BigHumpColName}}: info.{{.BigHumpColName}},{{end}}
        {{ end }}
    }
    return
}

func ({{.First}} *{{.BigHumpTableName}}) To{{.BigHumpTableName}}() (result *{{.ModelName}}.{{.BigHumpTableName}}) {
	if {{.First}}==nil{
		return
	}
    result = &{{.ModelName}}.{{.BigHumpTableName}}{
        Id: int64({{.First}}.ID),
	{{range .ColList }}{{if .Pointer}}{{.BigHumpColName}}: {{$First}}.{{.BigHumpColName}},{{end}}
	{{ end }}
    }
    return
}


func ({{.First}} *{{.BigHumpTableName}}) getByCon(db *gorm.DB) (recs []*{{.BigHumpTableName}}, err error) {
	tx := db.Model({{.BigHumpTableName}}{})
	if {{.First}}.ID != 0 {
		tx = tx.Where("id=?", {{.First}}.ID)
	}
    {{range .ColList }}
        {{if eq .Base false}}
        if {{$First}}.{{.BigHumpColName}} !=0  {
            tx = tx.Where("{{.ColName}}=?", {{$First}}.{{.BigHumpColName}})
        }
        {{end}}
    {{ end }}

	if err = tx.Find(&recs).Error; err != nil {
		return
	}
    return
}


func ({{.First}} *{{.BigHumpTableName}}) new(db *gorm.DB) error {
    if err := db.Model({{.BigHumpTableName}}{}).Create({{.First}}).Error; err != nil {
		return err
	}
    return nil
}

func ({{.First}} *{{.BigHumpTableName}}) update(db *gorm.DB) error {
	if err := db.Model({{.BigHumpTableName}}{}).
		Where("id=?", {{.First}}.ID).
		Updates({{.First}}).Error; err != nil {
		return err
	}
    return nil
}

func ({{.First}} *{{.BigHumpTableName}}) del(db *gorm.DB) error {
	if err := db.Model({{.BigHumpTableName}}{}).
		Where("id=?", {{.First}}.ID).
		Delete(&{{.BigHumpTableName}}{}).Error; err != nil {
		return err
	}
	return nil
}

func ({{.First}} *{{.BigHumpTableName}}) New() error {
	err := {{.ConnectDb}}.Transaction(func(tx *gorm.DB) (err error) {
		err = {{.First}}.new(tx)
		return
	})
	if err != nil {
		return err
	}
	return nil
}

func ({{.First}} *{{.BigHumpTableName}}) Update() error {
	err := {{.ConnectDb}}.Transaction(func(tx *gorm.DB) (err error) {
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
	err := {{.ConnectDb}}.Transaction(func(tx *gorm.DB) (err error) {
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
	db := {{.ConnectDb}}

    //检查是否存在
    con := {{.BigHumpTableName}}{Model: gorm.Model{ID: {{.First}}.ID}}
    olds, err := con.getByCon(db)
    if err != nil {
        return
    }
    if len(olds) == 0 {
        return nil, global.NewError(int32({{.ModelName}}.ErrCode_INVALID_PARAM), "记录不存在")
    }

	recs = append(recs, olds[0])
	return
}

func ({{.First}} *{{.BigHumpTableName}})QueryByCon(query *{{.ModelName}}.Query{{.BigHumpTableName}}All) (
    total int64,recs []*{{.BigHumpTableName}}, err error) {
	db := {{.ConnectDb}}
	tx := {{.ConnectDb}}.Model({{.BigHumpTableName}}{})

     {{range .ColList }}
        {{if eq .Base false}}
        if query.{{.BigHumpColName}} !="" {
            tx = tx.Where("{{.ColName}}=?", query.{{.BigHumpColName}})
        }
        {{end}}
    {{ end }} 



	if err = tx.Count(&total).Error; err != nil {
		return
	}

	if HasField({{.BigHumpTableName}}{}, query.GetQueryParam().GetSort().GetField()) {
		if query.GetQueryParam().GetSort().GetAsc() == int32(ASC) {
			tx = tx.Order(genColumnName(query.GetQueryParam().GetSort().Field) + " asc")
		} else {
			tx = tx.Order(genColumnName(query.GetQueryParam().GetSort().Field) + " desc")
		}
	} else {
		logger.Infof("忽略无效的排序字段(%s)", query.GetQueryParam().GetSort().GetField())
	}

	if err = tx.Offset(int(query.GetQueryParam().GetOffset())).
		Limit(int(query.GetQueryParam().GetCount())).
		Find(&recs).Error; err != nil {
		return
	}

	return
}
