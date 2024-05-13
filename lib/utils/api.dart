class Api{
  static const String baseUrl = 'https://bbs.api.robot-9.com/api';

  //首页
  static const String indexCategory = '$baseUrl/category/list';
  static const String indexList = '$baseUrl/content/list';
  static const String contentShow = '$baseUrl/content/show';

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

  //账号相关
  static const String login = '$baseUrl/passport/login';
  static const String register = '$baseUrl/passport/register';
  static const String logout = '$baseUrl/passport/logout';
  static const String resetPassword = '$baseUrl/passport/resetPassword';
  static const String sendCode = '$baseUrl/passport/sendCode';
  static const String user = '$baseUrl/user';

  static const String followedList = '$baseUrl/follower/followed/list';
  static const String fansList = '$baseUrl/follower/fans/list';
  static const String followerToggle = '$baseUrl/follower/toggle'; //关注 - 添加/取消

  
}