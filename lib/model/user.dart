class UserProfile {
  int? id;
  String? nickname;
  String? avatar;
  String? account;
  String? token;
  int? followedCount;
  int? fansCount;
  bool? followed;

  UserProfile({this.id, this.nickname, this.avatar, this.account,
    this.token, this.followedCount,this.fansCount, this.followed});

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
    if (json["followed"] is bool) {
      followed = json["followed"];
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
    _data["followed"] = followed;
    return _data;
  }
}
