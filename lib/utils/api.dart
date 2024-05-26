class Api{
  // static const String baseUrl = 'https://bbs.api.robot-9.com/api';

  static const String baseUrl = 'https://reptile-ja.ak12.cc/api';

  //首页
  static const String indexCategory = '$baseUrl/category/list';
  static const String indexList = '$baseUrl/content/list';
  static const String contentShow = '$baseUrl/content/show';
  static const String indexBanner = '$baseUrl/sectionData/list';

  //论坛
  static const String boardList = '$baseUrl/board/list';
  static const String threadList = '$baseUrl/thread/list';

  //消息
  static const String messageList = '$baseUrl/message/list';
  static const String messageBadge = '$baseUrl/message/badge';

  static const String threadCreate = '$baseUrl/thread/create';
  static const String threadShow = '$baseUrl/thread/show';
  static const String uploadFile = '$baseUrl/upload';

  //评论
  static const String commentList = '$baseUrl/comment/list';
  static const String commentCreate = '$baseUrl/comment/create';
  static const String like = '$baseUrl/like/toggle'; //点赞 - 添加/取消

  //账号相关
  static const String login = '$baseUrl/passport/login';
  static const String register = '$baseUrl/passport/register';
  static const String logout = '$baseUrl/passport/logout';
  static const String resetPassword = '$baseUrl/passport/resetPassword';
  static const String sendCode = '$baseUrl/passport/sendCode';
  static const String user = '$baseUrl/user';
  static const String userFavoriteList = '$baseUrl/user/favorite/list';
  static const String userCommentList = '$baseUrl/user/comment/list';
  static const String userSearch = '$baseUrl/user/search';
  static const String updatePassword = '$baseUrl/user/updatePassword';
  static const String updateAvatar = '$baseUrl/user/updateAvatar';
  static const String userUpdate = '$baseUrl/user/update';
  static const String appVersion = '$baseUrl/appVersion';

  static const String followedList = '$baseUrl/follower/followed/list';
  static const String fansList = '$baseUrl/follower/fans/list';
  static const String followerToggle = '$baseUrl/follower/toggle'; //关注 - 添加/取消


  static const String favoriteToggle = '$baseUrl/favorite/toggle'; //收藏 - 添加/取消
  static const String favoriteDelete = '$baseUrl/favorite/delete';  //收藏删除

  
}