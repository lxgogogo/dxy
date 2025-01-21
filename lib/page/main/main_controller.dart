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
    if (linkUri.scheme == 'kilofun') {
      final routeName = linkUri.queryParameters['routeName'] ?? '';
      switch (routeName) {
        /// kilofun:///kilofun.com?routeName=/marketDetail&contractAddress=HeLp6NuQkmYB4pYWo2zYs22mESHXPQYzXbB8n4V98jwC
      }
      // final base64GroupId = linkUri.queryParameters['groupId'] ?? '';
      // if (base64GroupId.isNotEmpty) {
      //   final groupID = utf8.decode(base64.decode(base64GroupId));
      //   if (groupID.isNotEmpty) _dealWithGroup(groupID);
      // } else if (base64UserId.isNotEmpty) {
      //   final userId = utf8.decode(base64.decode(base64UserId));
      //   if (userId.isNotEmpty && userId != UserStore.to.userId) {
      //     _dealWithUser(userId);
      //   }
      // }
    }
  }
}
