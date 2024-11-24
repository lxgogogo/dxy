import 'package:package_info_plus/package_info_plus.dart';

class AppUtil {
  static final AppUtil of = AppUtil._();
  AppUtil._();

  String? version;
  String? buildNumber;

  Future<void> init() async {
    await _requestAppInfo();
  }

  Future<void> _requestAppInfo() async {
    final res = await PackageInfo.fromPlatform();
    version = res.version;
    buildNumber = res.buildNumber;
  }

  Map<String, dynamic> get headerJson => {
        'version': version,
        'buildNumber': buildNumber,
      };
}
