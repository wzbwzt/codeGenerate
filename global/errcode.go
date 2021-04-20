package global

const (
	ErrCodeSuccess        = 10000
	ErrCodeBusy           = 20000
	ErrCodeParamNotEnough = 40001
	ErrCodeParamInvalid   = 40002
	ErrCodeInternal       = 40004
	ErrParamError         = 50001 //参数类错误码
	ErrInsufficientError  = 50002 //余额不足
	ErrDataWrongError     = 50003 //数据异常
	ErrNotAuthorization   = 50004 //没有授权信息
	ErrFailAuthorize      = 50005 //授权失败
	ErrCodeSended         = 50006 //验证码已发送
	ErrNoPriviledge       = 50007 //没有权限
	ErrNameCollisionError = 50008 //主键重复或名称重复
	ErrPrimaryInUseError  = 50009 //主键被引用
	ErrRPCError           = 50010 //调用微服务失败
	ErrNotExist           = 50011 //数据不存在
	ErrResourceInUse      = 50012 //数据使用中
	ErrNotRegisted        = 50013 //用户未注册
	ErrNotCheck           = 50014 //用户待审核
	ErrNotPass            = 50015 //用户未通过审核
	ErrDownLogFail        = 50016 //日志下载失败
	ErrTimeOut            = 50017 //请求超时
	ErrInvalidAction      = 50018 //无效的操作
)
