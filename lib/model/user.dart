import 'dart:convert';

class UserProfile {
  int? id;
  String? nickname;
  String? avatar;
  String? account;
  String? phone;
  String? username;
  String? googleAccount;
  String? appleAccount;
  String? telegramAccount;
  String? token;
  int? followedCount;
  int? fansCount;
  bool? followed;
  bool? isfans;
  UserLevel? userLevel;

  UserProfile(
      {this.id,
      this.nickname,
      this.avatar,
      this.account,
      this.token,
      this.followedCount,
      this.fansCount,
      this.followed,
      this.isfans,
      this.userLevel});

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
    if (json["phone"] is String) {
      phone = json["phone"];
    }
    if (json["username"] is String) {
      username = json["username"];
    }
    if (json["googleAccount"] is String) {
      googleAccount = json["googleAccount"];
    }
    if (json["appleAccount"] is String) {
      appleAccount = json["appleAccount"];
    }
    if (json["telegramAccount"] is String) {
      telegramAccount = json["telegramAccount"];
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
    if (json["isFans"] is bool) {
      isfans = json["isFans"];
    }
    if (json["userLevel"] is Map) {
      userLevel = UserLevel.fromJson(json["userLevel"]);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["nickname"] = nickname;
    _data["avatar"] = avatar;
    _data["account"] = account;
    _data["phone"] = phone;
    _data["username"] = username;
    _data["googleAccount"] = googleAccount;
    _data["appleAccount"] = appleAccount;
    _data["telegramAccount"] = telegramAccount;
    _data["token"] = token;
    _data["followedCount"] = followedCount;
    _data["fansCount"] = fansCount;
    _data["followed"] = followed;
    _data["isFans"] = isfans;
    return _data;
  }

  factory UserProfile.fromRawJson(String str) => UserProfile.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());
}

class UserLevel {
  int? favoriteCategory;

  UserLevel.fromJson(Map<String, dynamic> json) {
    if (json["favoriteCategory"] is int) {
      favoriteCategory = json["favoriteCategory"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["favoriteCategory"] = favoriteCategory;
    return _data;
  }
}
