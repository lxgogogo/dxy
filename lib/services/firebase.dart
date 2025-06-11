part of services;

// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   print("Handling a background message: ${message.messageId}");
// }

class FirebaseService extends GetxService {
  static FirebaseService get of => Get.find();

  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _androidChannel = const AndroidNotificationChannel(
    'depokers',
    'depokers Android',
    description: "depokers Android description",
  );

  String? fCMToken;

  Future<void> uploadFCMToken() async {
    try {
      final res = await CommonService.of.updatePushToken(deviceToken: fCMToken ?? '');
      if (res.isSuccess) {
      } else {
        ToastUtils.showToast(res.msg);
      }
    } catch (e) {
      Log.e(e.toString());
    }
  }

  // 初始化，获取设备token
  Future<void> initNotifications() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(provisional: true);

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        return;
      }
      bool canInit = false;
      if (Platform.isIOS) {
        final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        Log.d('apnsToken: $apnsToken');
        if (apnsToken != null) {
          canInit = true;
        }
      } else if (Platform.isAndroid) {
        final availability = await GoogleApiAvailability.instance.checkGooglePlayServicesAvailability();
        if (availability.value != 5) {
          canInit = true;
        }
      }
      if (canInit) {
        await FirebaseMessaging.instance.getAPNSToken();
        fCMToken = await FirebaseMessaging.instance.getToken();
        initPushNotifications();
        initLocalNotifications();
        uploadFCMToken();
      }
    } catch (e) {
      Log.e(e.toString());
    }
  }

  Future initPushNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);

    // 打开app时，会执行该回调，获取消息（通常是程序终止时，点击消息打开app的回调）
    FirebaseMessaging.instance.getInitialMessage().then(
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
