class UserProfile {
  int? id;
  String? account;
  String? nickname;
  String? avatar;
  String? token;
  int? followedCount;
  int? fansCount;

  UserProfile({this.id, this.nickname, this.avatar, this.account,
    this.token, this.followedCount,this.fansCount});

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
    if (json["followedCount"] is int) {
      followedCount = json["followedCount"];
    }
    if (json["fansCount"] is int) {
      fansCount = json["fansCount"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["nickname"] = nickname;
    _data["avatar"] = avatar;
    _data["account"] = account;
    _data["token"] = token;
    _data["followedCount"] = followedCount;
    _data["fansCount"] = fansCount;
    return _data;
  }
}
