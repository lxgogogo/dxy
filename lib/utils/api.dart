class Api {
  //首页
  static const String indexCategory = '/api/category/list';
  static const String indexList = '/api/content/list';
  static const String contentShow = '/api/content/show';
  static const String indexBanner = '/api/sectionData/list';
  static const String courseList = '/api/content/listCollectNew';
  static const String bookSuggest = '/api/content/bookSuggest';
  static const String hotVideo = '/api/searchHistory/hotVideo';

  //赛事
  static const String competitionRelated = '/api/content/competition/related';
  static const String competitionLoop = '/api/content/competition/loop';


  //论坛
  static const String boardList = '/api/board/list';
  static const String threadList = '/api/thread/list';

  //消息
  static const String messageList = '/api/message/list';
  static const String messageBadge = '/api/message/badge';
  static const String messageReadAll = '/api/message/readAll';

  static const String threadCreate = '/api/thread/create';
  static const String threadShield = '/api/thread/shield';
  static const String threadUserShield = '/api/thread/shield/user';
  static const String threadShow = '/api/thread/show';
  static const String uploadFile = '/api/upload';

  //评论
  static const String commentList = '/api/comment/list';
  static const String commentCreate = '/api/comment/create';
  static const String like = '/api/like/toggle'; //点赞 - 添加/取消

  //账号相关
  static const String login = '/api/passport/login';
  static const String register = '/api/passport/register';
  static const String reg = '/api/passport/reg';
  static const String logout = '/api/passport/logout';
  static const String resetPassword = '/api/passport/resetPassword';
  static const String sendCode = '/api/passport/sendCode';
  static const String user = '/api/user/information';
  static const String userFavoriteList = '/api/user/favorite/list';
  static const String delFavorite = '/api/favorite/delete';
  static const String userCommentList = '/api/user/comment/list';
  static const String userSearch = '/api/user/search';
  static const String updatePassword = '/api/user/updatePassword';
  static const String updateAvatar = '/api/user/updateAvatar';
  static const String userUpdate = '/api/user/update';
  static const String updateEmail = '/api/user/updateEmail';
  static const String updateUsername = '/api/user/updateUsername';
  static const String appVersion = '/api/appVersion';

  static const String followedList = '/api/follower/followed/list';
  static const String fansList = '/api/follower/fans/list';
  static const String followerToggle = '/api/follower/toggle'; //关注 - 添加/取消

  static const String favoriteToggle = '/api/favorite/toggle'; //收藏 - 添加/取消
  static const String favoriteDelete = '/api/favorite/delete'; //收藏删除
  static const String threadDelete = '/api/thread/delete'; //收藏删除
  static const String commentDelete = '/api/comment/delete'; //收藏删除

  static const String upCount = '/api/content/upCount';
  static const String threadUpCount = '/api/thread/upCount';
  static const String deleteAccount = '/api/user/deleteAccount';
  static const String trackEvent = '/api/userLog/save';
  static const String saveReview = '/api/statistics/save';
  static const String sourceCreate = '/api/source/create';

  static const String tagIndex = '/api/tag/index';
  static const String reportDefined = '/api/report/defined';
  static const String reportCreate = '/api/report/create';
  static const String searchTop = '/api/searchHistory/top';

  static const String thirdLogin = '/api/passport/thirdLogin';
  static const String bindThirdLogin = '/api/user/bindThirdLogin';
  static const String updatePhone = '/api/user/updatePhone';
  static const String queryLoginCode = '/api/scanLogin/queryLoginCode';
  static const String confirmLoginCode = '/api/scanLogin/confirmLoginCode';
  static const String sendVerifyCode = '/api/passport/sendVerifyCode';
  // 收藏
  static const String categoryList = '/api/favorite/category';
  static const String categorySave = '/api/favorite/category/save';
  static const String deleteFavorite = '/api/favorite/category/deleteFavorite';
  static const String deleteCategory = '/api/favorite/category/delete';
  static const String benefits = '/api/user/level/benefits';
  // 权益中心
  static const String userEquity = '/api/user/equity';

  static const String topHeatTag = '/api/tag/topHeatTag';

  // 站内信
  static const String noticeRead = '/api/notifies/read';
  static const String noticeList = '/api/notifies/list';
  static const String noticeDelete = '/api/notifies/del';
  static const String noticeMoreDelete = '/api/notifies/batchDel';
  static const String noticeBadge = '/api/message/badge';

  ///push
  static const String updatePushToken = '/api/user/updatePushToken';

  static const String courseGroupIndex = '/api/course/group/index';
  static const String courseGroupChoose = '/api/course/group/choose';
  static const String courseDefined = '/api/course/defined';
  static const String courseTop = '/api/course/top';
  static const String courseIndex = '/api/course/index';
  static const String courseRead = '/api/course/read';
  static const String courseStart = '/api/course/start';
  static const String courseInfo = '/api/course/info';
  static const String coursePractise = '/api/course/practise';
  static const String courseAnswer = '/api/course/answer';
  static const String coursePunch = '/api/course/punch';
  static const String courseRemind = '/api/course/remind';
  static const String courseChallenge = '/api/course/challenge';
}
