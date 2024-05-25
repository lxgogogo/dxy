enum EventBusAction {
  //刷新首页
  refreshPersonalProfile,
  //关闭登录页面
  closeLoginPage,
  //刷新论坛帖子详情
  refreshForumPostDetail,

  //退出登录之后首页tab通知切换到0位置
  noticeMainTabSwitchHome,
  //发布帖子成功后刷新论坛列表数据
  refreshForumList,
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
      case EventBusAction.noticeMainTabSwitchHome:
        return '首页tab通知切换到0位置';
      case EventBusAction.refreshForumList:
        return '发布帖子成功后刷新论坛列表数据';
      default:
        return '未知';
    }
  }
}
