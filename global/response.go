package global

type Response struct {
	Code int         `json:"code"`
	Msg  string      `json:"msg"`
	Data interface{} `json:"data"`
}

type Accessory struct {
	ID   string `json:"id"`
	Name string `json:"name"`
}
