
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:holdem/utils/app_util.dart';
import 'package:holdem/utils/devices_util.dart';

class ThirdSDKConfig {
  static Future<void> init() async {
    // await Connectivity().checkConnectivity();
    // if (!KxPlatformUtils.of.isDesktop) {
    //   KangXunUpdateUtil.of.init();
    //   RecognitionUtil.of.init();
    //   // 提前初始化，优化第一次拉起速度
    //   BDFaceAuthUtil.of.initBdFace();
    //   FlutterTTSUtil.of.init();
    //   await AliPhoneAuthUtil.of.initWith(
    //     _iosAliAuthSecretKey,
    //     _androidAliAuthSecretKey,
    //   );
    // }
    // // 发布后再初始化日志上报
    // if (Env.isDistribute) {
    //   FlutterBugly.init(
    //     androidAppId: _androidAppIdOfBugly,
    //     iOSAppId: _iosAppIdOfBugly,
    //   );
    //   //  SentryUtil.of.initialize();
    // }
    await DevicesUtil.of.init();
    await AppUtil.of.init();
  }
}
