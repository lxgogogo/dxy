class Api{
  static const String baseUrl = 'https://bbs.api.robot-9.com/api';

  //论坛
  static const String boardList = '$baseUrl/board/list';
  static const String threadList = '$baseUrl/thread/list';


  //账号相关
  static const String login = '$baseUrl/passport/login';
  static const String register = '$baseUrl/passport/register';
  static const String logout = '$baseUrl/passport/logout';
  static const String resetPassword = '$baseUrl/passport/resetPassword';
  static const String sendCode = '$baseUrl/passport/sendCode';

  
}