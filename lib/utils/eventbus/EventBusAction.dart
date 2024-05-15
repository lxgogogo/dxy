enum EventBusAction {
  //刷新首页
  refreshPersonalProfile,
  //关闭登录页面
  closeLoginPage,
  //刷新论坛帖子详情
  refreshForumPostDetail,
}

extension DioErrorTypeExtension on EventBusAction {
  String get eventBusTypeName {
    switch (this) {
      case EventBusAction.refreshPersonalProfile:
        return '刷新个人资料页面';
      case EventBusAction.closeLoginPage:
        return '关闭登录页面';
      case EventBusAction.refreshForumPostDetail:
        return '刷新论坛帖子详情';
      default:
        return '未知';
    }
  }
}
