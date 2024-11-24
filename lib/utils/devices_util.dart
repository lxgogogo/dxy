import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:holdem/constants.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/utils/secure_storage_util.dart';

class DevicesUtil {
  static final DevicesUtil of = DevicesUtil._();

  DevicesUtil._();

  // 预初始化，防止在使用 get 时，deviceInfo 还未完成初始化
  Future<void> init() async {
    await _requestDeviceInfo();
  }

  IosDeviceInfo? _iosInfo;
  MacOsDeviceInfo? _macOsInfo;
  AndroidDeviceInfo? _androidInfo;
  WindowsDeviceInfo? _windowsInfo;

  String get _androidBrand => _androidInfo?.brand.toLowerCase() ?? '';

  String? deviceID;
  String? osVersion;

  String get platform {
    if (Platform.isIOS) {
      return 'iOS';
    }
    if (Platform.isAndroid) {
      return 'android';
    }
    return Platform.operatingSystem;
  }

  Future<void> _requestDeviceInfo() async {
    if (Platform.isIOS) {
      _iosInfo = await DeviceInfoPlugin().iosInfo;
      deviceID = await _getDeviceId(_iosInfo?.identifierForVendor);
      osVersion = _iosInfo?.systemVersion ?? '';
    } else if (Platform.isAndroid) {
      _androidInfo = await DeviceInfoPlugin().androidInfo;
      deviceID = await _getDeviceId(_androidInfo?.id);
      osVersion = _androidInfo?.version.sdkInt.toString();
    } else if (Platform.isMacOS) {
      _macOsInfo = await DeviceInfoPlugin().macOsInfo;
      deviceID = await _getDeviceId(_macOsInfo?.systemGUID);
      osVersion = '${_macOsInfo?.majorVersion}.${_macOsInfo?.minorVersion}';
    } else if (Platform.isWindows) {
      _windowsInfo = await DeviceInfoPlugin().windowsInfo;
      deviceID = await _getDeviceId(_windowsInfo?.deviceId);
      osVersion = '${_windowsInfo?.majorVersion}.${_windowsInfo?.minorVersion}';
    }
  }

  Future<String?> _getDeviceId(String? id) {
    return SecureStorageUtil.of
        .read(Constants.localSecureDeviceId)
        .then((value) {
      if (value == null) {
        SecureStorageUtil.of.write(
          Constants.localSecureDeviceId,
          id?.generateMD5 ?? 'unknown',
        );
        return id?.generateMD5 ?? 'unknown';
      } else {
        return value;
      }
    }).catchError((Object e) {
      return '';
    });
  }

  Map<String, dynamic> get headerJson => {
        'Device-Id': deviceID,
        'Device-Type': platform,
      };

  String getPlatform() {
    final environment = Platform.environment;
    return '';
  }

  bool get isBrandXiaoMi {
    if (!Platform.isAndroid) return false;
    return _androidBrand.contains("xiaomi");
  }

  bool get isBrandHuawei {
    if (!Platform.isAndroid) return false;
    return _androidBrand.contains("huawei");
  }

  bool get isBrandMeizu {
    if (!Platform.isAndroid) return false;
    return _androidBrand.contains("meizu") ||
        _androidBrand.contains("22c4185e");
  }

  bool get isBrandOppo {
    if (!Platform.isAndroid) return false;
    return _androidBrand.contains("oppo") ||
        _androidBrand.contains("realme") ||
        _androidBrand.contains("oneplus");
  }

  bool get isBrandVivo {
    if (!Platform.isAndroid) return false;
    return _androidBrand.contains("vivo");
  }

  bool get isBrandHonor {
    if (!Platform.isAndroid) return false;
    return _androidBrand.contains("honor");
  }

  bool get isBrandIPhone {
    return Platform.isIOS;
  }

  // 获取手机型号
  String get getBrand {
    if (Platform.isIOS) {
      return '${_iosInfo?.utsname.nodename ?? 'iPhone'}: ${_iosInfo?.utsname.machine ?? _iosInfo?.model ?? 'ios'}';
    }
    if (Platform.isAndroid) {
      final model = _androidInfo?.model ?? 'android';
      return "$_androidBrand: $model";
    }

    if (Platform.isMacOS) {
      return _macOsInfo?.model ?? 'Mac';
    }

    if (Platform.isWindows) {
      return _windowsInfo?.productName ?? 'Windows';
    }

    return "other";
  }
}
