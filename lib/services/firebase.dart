part of services;

// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   print("Handling a background message: ${message.messageId}");
// }

class FirebaseService extends GetxService {
  static FirebaseService get of => Get.find();

  final _firebaseMessaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _androidChannel = const AndroidNotificationChannel(
    '德学院',
    '德学院 Android',
    description: "德学院 Android description",
  );

  String? fCMToken;

  Future<void> uploadFCMToken() async {
    final res = await CommonService.of.updatePushToken(deviceToken: fCMToken ?? '');
    if (res.isSuccess) {
    } else {
      ToastUtils.showToast(res.msg);
    }
  }

  // 初始化，获取设备token
  Future<void> initNotifications() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission();

    /// authorized：用户授予了权限。
    /// denied：用户拒绝了权限。
    /// notDetermined：用户尚未选择是否要授予权限。
    /// provisional：用户授予了临时权限。
    // 注意：在 Android 13 之前的版本中，如果用户未在操作系统设置中停用应用的通知，
    // 则 authorizationStatus 会返回 authorized。
    // 在 Android 13 及更高版本中，无法确定用户是否已选择授予/拒绝权限。
    // denied 值表示未确定或已拒绝的权限状态，您需要自行跟踪是否已发出权限请求。
    Log.d('User granted permission: ${settings.authorizationStatus}');

    bool canInit = false;
    if (Platform.isIOS) {
      final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      Log.d('apnsToken: $apnsToken');
      if (apnsToken != null) {
        canInit = true;
      }
    } else if (Platform.isAndroid) {
      canInit = true;
    }
    if (canInit) {
      await _firebaseMessaging.getAPNSToken();
      fCMToken = await _firebaseMessaging.getToken();
      initPushNotifications();
      initLocalNotifications();
      uploadFCMToken();
    }
  }

  Future initPushNotifications() async {
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);

    // 打开app时，会执行该回调，获取消息（通常是程序终止时，点击消息打开app的回调）
    _firebaseMessaging.getInitialMessage().then(
          (RemoteMessage? message) {
        if (message == null) return; // 没有消息不执行后操作
        handleMessage(message);
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);

    /// 前台消息，android不会通知，所以需要自定义本地通知（iOS没有前台消息，iOS的前台消息和后台运行时一样的效果）
    FirebaseMessaging.onMessage.listen(
          (RemoteMessage message) {
        final notification = message.notification;
        if (notification == null) return;
        if (Platform.isIOS) return;
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _androidChannel.id,
              _androidChannel.name,
              channelDescription: _androidChannel.description,
              icon: '@mipmap/ic_launcher',
            ),
          ),
          payload: jsonEncode(message.toMap()),
        );
      },
    );
  }

  void handleMessage(RemoteMessage message) {
    Log.d('${message.toMap()}');
  }

  // 本地消息，处理android的前台消息
  Future initLocalNotifications() async {
    const iOS = DarwinInitializationSettings();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android, iOS: iOS);
    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        try {
          final message = RemoteMessage.fromMap(jsonDecode(response.payload!));
          handleMessage(message);
        } catch (e) {
          Log.d(e.toString());
        }
      },
    );
    final platform =
    _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
  }
}
