package global

type SearchOrderType int

const (
	SearchOrderDesc SearchOrderType = iota
	SearchOrderAsc
)

type SearchParamPaging struct {
	PageSize int `json:"pageSize"`
	Current  int `json:"current"`
}

type SearchParamSorting struct {
	Field string          `json:"field"`
	Order SearchOrderType `json:"order"`
}

type CommonSearchParam struct {
	Paging SearchParamPaging  `json:"pagination"`
	Sorter SearchParamSorting `json:"sorter"`
}

type ServiceNameType int

const (
	OnlyOneName   = iota // 只使用一个服务名时，通用的方法名要加表名后缀。 eg: table:sys_user method: Add AddUser
	UsedTableName        // 使用表名为服务名
)
