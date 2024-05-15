///{code: 200, message: success, data:
///{forced: false, description: 升级了什么\r\n升级了什么\r\n升级了什么\r\n升级了什么\r\n升级了什么,
///androidVersion: 1.0.0, androidUrl: , androidBundle: https://xxx.com/a, iosVersion: 1.0.0, iosUrl: , iosBundle: }}
class AppVersion {
  bool? forced; // 是否强制更新
  String? description;
  String? androidVersion;
  String? androidUrl;
  String? androidBundle;
  String? iosVersion;
  String? iosUrl;
  String? iosBundle;

  AppVersion(
      {this.forced,
      this.description,
      this.androidVersion,
      this.androidUrl,
      this.androidBundle,
      this.iosVersion,
      this.iosUrl,
      this.iosBundle});

  AppVersion.fromJson(Map<String, dynamic> json) {
    if (json["forced"] is bool) {
      forced = json["forced"];
    }
    if (json["description"] is String) {
      description = json["description"];
    }
    if (json["androidVersion"] is String) {
      androidVersion = json["androidVersion"];
    }
    if (json["androidUrl"] is String) {
      androidUrl = json["androidUrl"];
    }
    if (json["androidBundle"] is String) {
      androidBundle = json["androidBundle"];
    }
    if (json["iosVersion"] is String) {
      iosVersion = json["iosVersion"];
    }
    if (json["iosUrl"] is String) {
      iosUrl = json["iosUrl"];
    }
    if (json["iosBundle"] is String) {
      iosBundle = json["iosBundle"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["forced"] = forced;
    _data["description"] = description;
    _data["androidVersion"] = androidVersion;
    _data["androidUrl"] = androidUrl;
    _data["androidBundle"] = androidBundle;
    _data["iosVersion"] = iosVersion;
    _data["iosUrl"] = iosUrl;
    _data["iosBundle"] = iosBundle;
    return _data;
  }
}
