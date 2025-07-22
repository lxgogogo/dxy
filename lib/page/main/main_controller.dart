part of 'main_screen.dart';

class MainController extends GetxController with WidgetsBindingObserver {
  static MainController get of => Get.find<MainController>();

  int tabIndex = 0;

  StreamSubscription? eventSubscription;
  StreamSubscription? refreshNoticeSubs;

  ///deeplink
  final AppLinks _appLinks = AppLinks();

  PageController pageController = PageController();

  void onTabBarItem(int index) {
    if (index > 2) {
      if (!UserStore.of.isLogin) {
        Get.toNamed(Routes.login);
        return;
      }
    } else if (index == 2 && UserStore.of.isLogin) {
      if (!UserStore.of.hasCourseGroup) {
        Get.toNamed(Routes.selectCourses);
        return;
      }
    }
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 100),
      curve: Curves.ease,
    );

    _checkAppVersion();

    saveReview();

    /// 消息内部自己去刷
    if (index != 3) {
      UserStore.of.refreshBadge();
    }

    switch (index) {
      case 0:
        TrackUtils.trackEvent(userLogType: '100001');
        break;
      case 1:
        TrackUtils.trackEvent(userLogType: '100005');
        break;
      case 3:
        TrackUtils.trackEvent(userLogType: '100010');
        break;
      case 4:
        TrackUtils.trackEvent(userLogType: '100009');
        break;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _checkAppVersion();
        // if (timer?.isActive != true) {
        //   timer?.cancel();
        //   timer = Timer.periodic(
        //     const Duration(seconds: 5),
        //     loadMessageBadge,
        //   );
        // }
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
        break;
      case AppLifecycleState.paused:
        // timer?.cancel();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void onReady() {
    super.onReady();
    pageController.addListener(() {
      tabIndex = pageController.page?.toInt() ?? 0;
      safeUpdate();
      DebounceThrottle.throttle(() {
        EventBusUtil.of.fire(EventChangeMainTab(tabIndex));
      });
    });
    eventSubscription = EventBusUtil.of.on<EventLogout>().listen((event) {
      pageController.jumpToPage(0);
    });
    refreshNoticeSubs = EventBusUtil.of.on<EventRefreshNotice>().listen((event) {
      UserStore.of.refreshBadge();
    });
    _initAppLinks();
    _checkAppVersion();
    UserStore.of.refreshBadge();
    // timer = Timer.periodic(
    //   const Duration(seconds: 5),
    //   loadMessageBadge,
    // );
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    eventSubscription?.cancel();
    refreshNoticeSubs?.cancel();
    // timer?.cancel();
    super.onClose();
  }

  void _checkAppVersion() async {
    await AppVersionChecker.of.checkVersion();
  }

  Future<void> _initAppLinks() async {
    // final initialUri = await _appLinks.getInitialLink();
    // if (initialUri != null) {
    //   dealWithLink(initialUri);
    // }
    _appLinks.uriLinkStream.listen(dealWithLink);
  }

  void dealWithLink(Uri linkUri) {
    // if (linkUri.scheme == 'holdem') {
    if (linkUri.path.contains('details/')) {
      try {
        var detailsPart = linkUri.path.split('details/')[1];
        String id = '';
        String type = '';
        String childId = '';

        if (detailsPart.startsWith('videoList')) {
          var parts = detailsPart.split('-');
          type = 'videoList';
          id = parts[1].split('.')[0];
          childId = linkUri.queryParameters['id'] ?? '';
        } else {
          var parts = detailsPart.split('-');
          type = parts[0];
          id = parts[1].split('.')[0];
        }

        final intId = int.tryParse(id);
        if (intId == null) return;
        Get.until((route) => route.settings.name == Routes.main);
        switch (type) {
          case 'article':
            Get.toNamed(Routes.articleDetail, arguments: intId);
            break;
          case 'thread':
            Get.toNamed(Routes.feedDetail, arguments: intId);
            break;
          case 'book':
            Get.toNamed(Routes.bookDetail, arguments: intId);
            break;
          case 'video':
            Get.toNamed(Routes.videoDetail, arguments: {'id': intId});
            break;
          case 'videoList':
            final intChildId = int.tryParse(childId);
            Get.toNamed(Routes.videoDetail, arguments: {'id': intId, 'childId': intChildId});
            break;
        }
        CommonService.of.sourceCreate(linkUri);
      } catch (e) {
        Log.d(e.toString());
      }
    }
    // }
  }

  Future<void> saveReview() async {
    if (UserStore.of.isLogin) {
      try {
        await CommonService.of.saveReview();
      } catch (e) {}
    }
  }

  String getTabTypeName(int index) {
    switch (index) {
      case 0:
        return 'home';
      case 1:
        return 'feed';
      case 2:
        return 'course';
      case 3:
        return 'message';
      case 4:
        return 'mine';
    }
    return '';
  }
}
