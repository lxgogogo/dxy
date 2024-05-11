enum EventBusAction {
  //刷新首页
  refreshPersonalProfile,
  //关闭登录页面
  closeLoginPage,
}

extension DioErrorTypeExtension on EventBusAction {
  String get eventBusTypeName {
    switch (this) {
      case EventBusAction.refreshPersonalProfile:
        return '刷新个人资料页面';
        case EventBusAction.closeLoginPage:
        return '关闭登录页面';
      default:
        return '未知';
    }
  }
}
