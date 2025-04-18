enum EventBusAction {
  //刷新首页
  refreshPersonalProfile,
  //关闭登录页面
  closeLoginPage,
  //刷新论坛帖子详情
  refreshForumPostDetail,
  refreshSearchChildView,

  //退出登录之后首页tab通知切换到0位置
  noticeMainTabSwitchHome,
  //刷新我的收藏列表
  // refreshMineFavoriteList,
  refreshMineLikeList,
  //更新板块tab数据
  updateBoardTabData,
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
      // case EventBusAction.refreshMineFavoriteList:
      //   return '刷新我的收藏列表';
      case EventBusAction.updateBoardTabData:
        return '更新板块tab数据';
      case EventBusAction.refreshSearchChildView:
        return 'refreshSearchChildView';
      default:
        return '未知';
    }
  }
}
