import 'dart:ui';

abstract class Constants {
  static const Size designSize = Size(375, 812);

  static const token = 'storage_token';
  static const localUser = 'storage_user_model';
  static const localLanguage = 'storage_language';
  static const localTheme = 'storage_theme_mode';
  static const localSecureDeviceId = 'storage_secure_device_id';
  static const localDidAgreeUseApp = 'storage_agree_use_app';
  static const localIgnoredVersions = 'storage_ignored_versions';
  static const localLastPopupDate = 'storage_last_popup_date';
  static const localSelectedCourseGroupId = 'storage_selected_course_group_id';

  // 密码正则表达式
  static final passwordRegExp = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)[A-Za-z\d\u0021\u0022\u0023\u0024\u0025\u0026\u0027\u0028\u0029\u002A\u002B\u002C\u002D\u002E\u002F\u003A\u003B\u003D\u003C\u003E\u003F\u0040\u005B\u005D\u005E\u005F\u0060\u007B\u007D\u007C\u007E]{8,12}$');

  // 手机号正则表达式：1开头，第二位3-9，后面9位数字
  static final phoneRegExp = RegExp(r'^1[3-9]\d{9}$');

  // 账号正则表达式：6-15位英数字，大小写不同
  static final accountRegExp = RegExp(r'^[A-Za-z0-9]{6,15}$');

  // 验证码正则表达式：6位数字
  static final codeRegExp = RegExp(r'^\d{6}$');

  // 密码非法字符正则表达式：只允许英文字母、数字及特殊字符
  static final containsInvalidChars = RegExp(
      r'^[A-Za-z\d\u0021\u0022\u0023\u0024\u0025\u0026\u0027\u0028\u0029\u002A\u002B\u002C\u002D\u002E\u002F\u003A\u003B\u003D\u003C\u003E\u003F\u0040\u005B\u005D\u005E\u005F\u0060\u007B\u007D\u007C\u007E]*$');

  static const String verifyTypeEmail = "EMAIL";
  static const String verifyTypePhone = "PHONE";

  static const String verifyCodeTypeRegister = "REGISTER";
  static const String verifyCodeTypeResetPassword = "RESET_PASSWORD";
  static const String verifyCodeTypeChangeEmail = "CHANGE_EMAIL";
  static const String verifyCodeTypeDeleteAccount = "DELETE_ACCOUNT";
  static const String verifyCodeTypeChangePhone = "CHANGE_PHONE";
}
