part of 'main_screen.dart';

class MainController extends GetxController {
  int currentIndex = 0;

  StreamSubscription? eventSubscription;

  ///deeplink
  final AppLinks _appLinks = AppLinks();

  void onTabBarItem(int index) {
    if (index == 2 || index == 3) {
      if (!UserStore.of.isLogin) {
        ToastUtils.showToast('请先登录');
        Get.toNamed(Routes.login);
        return;
      }
    }
    currentIndex = index;
    safeUpdate();

    CommonService.of.saveReview();
  }

  @override
  void onReady() {
    super.onReady();
    _initAppLinks();
    _checkAppVersion();
    eventSubscription = EventBusUtil.of.on<EventResetMainTab>().listen((event) {
      currentIndex = 0;
      safeUpdate();
    });
  }

  @override
  void onClose() {
    eventSubscription?.cancel();
    super.onClose();
  }

  void _checkAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;

    NetRequest().appVersion((data) {
      final appVersion = AppVersion.fromJson(data);
      final latestVersion = Platform.isAndroid ? appVersion.androidVersion : appVersion.iosVersion;
      if (latestVersion?.isNotEmpty == true) {
        if (latestVersion!.compareTo(currentVersion) > 0) {
          if (Get.context == null) return;
          final forceUpdate = appVersion.forced ?? false;
          if (forceUpdate) {
            showDialog(
              barrierDismissible: false,
              context: Get.context!,
              builder: (context) => CommonDialog(
                title: '更新以获得最佳体验',
                onConfirm: () {
                  launchURL(appVersion);
                },
                onlyConfirm: true,
              ),
            );
          } else {
            showDialog(
              barrierDismissible: false,
              context: Get.context!,
              builder: (context) => CommonDialog(
                title: '有新版本可以更新',
                confirmText: '立即更新',
                onConfirm: () {
                  Navigator.of(context).pop();
                  launchURL(appVersion);
                },
                cancelText: '下次再说',
              ),
            );
          }
        }
      }
    });
  }

  void launchURL(AppVersion appVersion) {
    String? url;
    if (Platform.isAndroid) {
      url = appVersion.androidUrl;
    } else {
      url = appVersion.iosUrl;
    }
    if (url?.isNotEmpty == true) {
      launchUrlString(url!, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _initAppLinks() async {
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      dealWithLink(initialUri);
    }
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
            CommonService.of.sourceCreate(linkUri);
            break;
          case 'thread':
            Get.toNamed(Routes.feedDetail, arguments: intId);
            CommonService.of.sourceCreate(linkUri);
            break;
          case 'book':
            Get.toNamed(Routes.bookDetail, arguments: intId);
            CommonService.of.sourceCreate(linkUri);
            break;
          case 'video':
            Get.toNamed(Routes.videoDetail, arguments: {'id': intId});
            CommonService.of.sourceCreate(linkUri);
            break;
          case 'videoList':
            final intChildId = int.tryParse(childId);
            Get.toNamed(Routes.videoDetail, arguments: {'id': intId, 'childId': intChildId});
            CommonService.of.sourceCreate(linkUri);
            break;
        }
      } catch (e) {
        Log.d(e.toString());
      }
    }
    // }
  }
}
