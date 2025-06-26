part of 'app_pages.dart';

class AppRouteObserver<R extends Route<dynamic>> extends RouteObserver<R> {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != Routes.splash) {
      CommonService.of.saveReview();
    }
    final name = route.settings.name ?? '';
    if (name.isNotEmpty) Routes.history.add(name);
    switch (name) {
      case Routes.login:
        TrackUtils.trackEvent(userLogType: '118001');
        break;
      case Routes.articleDetail:
        // TrackUtils.trackEvent(userLogType: '104002', params: Get.arguments);
        break;
      case Routes.bookDetail:
        // TrackUtils.trackEvent(userLogType: '106001', params: Get.arguments);
        break;
      case Routes.feedDetail:
        // TrackUtils.trackEvent(userLogType: '108002', params: Get.arguments);
        break;
      case Routes.feedPost:
        TrackUtils.trackEvent(userLogType: '108005');
        break;
    }
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final name = route.settings.name ?? '';
    if (name.isNotEmpty) Routes.history.remove(name);
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute?.settings.name != Routes.splash) {
      CommonService.of.saveReview();
    }
    if (newRoute != null) {
      final index = Routes.history.indexWhere((element) {
        return element == oldRoute?.settings.name;
      });
      final name = newRoute.settings.name ?? '';
      if (name.isNotEmpty) {
        if (index > -1) {
          Routes.history[index] = name;
        } else {
          Routes.history.add(name);
        }
      }
      switch (name) {
        case Routes.login:
          TrackUtils.trackEvent(userLogType: '118001');
          break;
        case Routes.articleDetail:
          // TrackUtils.trackEvent(userLogType: '104002', params: Get.arguments);
          break;
        case Routes.bookDetail:
          // TrackUtils.trackEvent(userLogType: '106001', params: Get.arguments);
          break;
        case Routes.feedDetail:
          // TrackUtils.trackEvent(userLogType: '108002', params: Get.arguments);
          break;
        case Routes.feedPost:
          TrackUtils.trackEvent(userLogType: '108005');
          break;
      }
    }
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final name = route.settings.name ?? '';
    if (name.isNotEmpty) Routes.history.remove(name);
    super.didRemove(route, previousRoute);
  }
}
