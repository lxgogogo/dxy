class UserProfile {
  int? id;
  String? account;
  String? nickname;
  String? avatar;
  String? token;

  UserProfile({this.id, this.nickname, this.avatar, this.account, this.token});

  UserProfile.fromJson(Map<String, dynamic> json) {
    if (json["id"] is int) {
      id = json["id"];
    }
    if (json["nickname"] is String) {
      nickname = json["nickname"];
    }
    if (json["avatar"] is String) {
      avatar = json["avatar"];
    }
    if (json["account"] is String) {
      account = json["account"];
    }
    if (json["token"] is String) {
      token = json["token"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["nickname"] = nickname;
    _data["avatar"] = avatar;
    _data["account"] = account;
    _data["token"] = token;
    return _data;
  }
}
