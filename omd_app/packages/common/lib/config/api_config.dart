class ApiConfig {
  ApiConfig._internal();

  static String getAppVersionInfo = "";
  static String uploadImage = "";

  // Authentication

  static String get broswerRecord => "/Member/BrowsingRecordList";

  // Discover
  static String get channelAds => "/Web/ChannelAds"; //tab+广告
  static String get videoDetail => "/Web/VideoDetail"; //视频详情
  static String get chanelList => "/BBS/ChanelList";
  static String get postDetail => "/BBS/PostDetail"; //吃瓜黑料->详情
  static String get subChannelDetail => "/BBS/SubChannelDetail";
  static String get like => "/BBS/Like"; //吃瓜黑料->点赞
  static String get postCommentList => "/BBS/PostCommentList"; //评论列表
  static String get relatedRecommendList => "/BBS/RelatedRecommendList"; //相关推荐
  static String get getHotSearch => "/Web/HotSearchKeywordList"; // 获取热搜词
  static String get searchAll => "/Web/SearchByKeyword"; // 全站搜索
  static String get getRankingList => "/Web/SearchRank";
  static String get getChildCount => "/Member/GetChildCount"; //邀请接口中
  static String get collectionDetail => "/Collection/CollectionDetail";
  static String get collecionList => "/Collection/CollectionList"; // 专题列表
  static String get collectionLike => "/Collection/Like"; // 专题点赞
  static String get collectionCollect => "/Collection/Collect"; // 专题收藏
  static String get collectionCollectList =>
      "/Collection/CollectList"; // 收藏的专题列表
  static String get indexCollectionList =>
      "/Collection/IndexCollectionList"; // 合集
  static String get adsList => "/Web/AdsList"; // AdsList
  static String get adsListTwo => "/Web/AdsList2"; // AdsList
  static String get daySendVideoList => "/Web/DaySendVideoList"; // 每日视频列表
  static String get ShortMovieDetail => "/ShortMovie/ShortMovieDetail"; // 短剧详情
  static String get ShortMovieChannel => "/ShortMovie/Channel"; // 短剧频道
  static String get guessShortMovieList =>
      "/ShortMovie/GuessShortMovieList"; // 猜你喜欢
  static String get shortMovieLike => "/ShortMovie/Like"; // 短剧点赞
  static String get dyCommentList => "/Web/CommentList"; // 抖音评论列表
  static String get commentList => "/ShortMovie/CommentList"; // 短剧评论列表
  static String get shortMovieLikeComment => "/ShortMovie/LikeComment";
  static String get webLikeComment => "/Web/LikeComment";
  static String get BBSLikeComment => "/BBS/LikeComment";
}
