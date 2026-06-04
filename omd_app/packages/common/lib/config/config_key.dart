/// 远程配置项键名，与服务端 [/Web/Config2] pKey（`enum.name`）一致。
enum ConfigKey {
  /// 社区随机页码
  BBSRandomPage,

  /// 底部弹窗 0关闭，1开启
  footerpop, // H5 底部下载开关
  /// 发帖设置，value1=0不允许前端发帖，=1允许，value2 会员每日允许发帖数
  bbssetting, // 暂无该功能
  /// 短视频页码随机
  ShortVideoRandomPage, // 抖音短视频 已用代码随机
  /// 短视频列表页页码随机
  ShortVideoListRandomPage, // 短视频列表 已用代码随机
  /// 是否开启反馈，1开启，0关闭 反馈功能未实现
  feedback, // 反馈功能未实现
  /// # 广告设置，value1:首页大家都在玩广告显示个数 -1不限制
  adssetting,

  /// 搜索框域名
  SEACHDomain,

  /// # 启动页广告时间
  StartAdTime,

  /// 客服链接
  Chat, // 暂无客服功能
  /// 0关闭matomo，1开启
  matomok,

  /// 丢失页面配置
  SpareData,

  /// # 分享链接
  SharedUrl,

  /// # 是否允许评论，value1=0禁止评论，=1允许评论，value2每天最多评论数，value3评论间隔时间秒
  commentsetting,

  /// # App设置，value1=广场地址
  appsetting,

  /// 视频cdn
  PlayDomain,

  /// cdn地址 1=普通cdn，2 未加密cdn
  CDNURL,

  /// # 视频播放广告，value1 0不允许跳过，1允许，value2 可跳过秒数
  PrePlayAdTime,

  /// # 搜索设置，value1=0关闭搜索，1开启，value2=0未登录不允许搜索，=1允许，value3搜索间隔时间秒
  searchsetting,

  /// # 视频页面分类进入某类型广告开关
  catads,

  /// # 自研统计用
  mginstallsetting,

  TVSetting,
  TVMidnightSetting,
  WorldCupLinkSetting,
}
