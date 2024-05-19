class MessageBean{
  int? id;
  String? type;
  String? quote;
  String? jumpType;
  int? jumpId;
  String? itemType;
  int? itemId;
  String? description;
  DateTime? createdAt;
  MessageUser? fromUser;

  MessageBean.fromJson(Map<String, dynamic> json) {
    if (json["id"] is int) {
      id = json["id"];
    }
    if (json["type"] is String) {
      type = json["type"];
    }
    if (json["quote"] is String) {
      quote = json["quote"];
    }
    if (json["jumpType"] is String) {
      jumpType = json["jumpType"];
    }
    if (json["jumpId"] is int) {
      jumpId = json["jumpId"];
    }
    if (json["itemType"] is String) {
      itemType = json["itemType"];
    }
    if (json["itemId"] is int) {
      itemId = json["itemId"];
    }
    if (json["description"] is String) {
      description = json["description"];
    }
    if (json["createdAt"] is String) {
      createdAt = DateTime.parse(json["createdAt"]);
    }
    if (json["fromUser"] is Map) {
      fromUser = MessageUser.fromJson(json["fromUser"]);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["type"] = type;
    _data["quote"] = quote;
    _data["jumpType"] = jumpType;
    _data["jumpId"] = jumpId;
    _data["itemType"] = itemType;
    _data["itemId"] = itemId;
    _data["description"] = description;
    _data["createdAt"] = createdAt;
    _data["fromUser"] = fromUser?.toJson();
    return _data;
  }



}

class MessageUser{
  int? id;
  String? avatar;
  String? nickname;

  MessageUser.fromJson(Map<String, dynamic> json) {
    if (json["id"] is int) {
      id = json["id"];
    }
    if (json["avatar"] is String) {
      avatar = json["avatar"];
    }
    if (json["nickname"] is String) {
      nickname = json["nickname"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["avatar"] = avatar;
    _data["nickname"] = nickname;
    return _data;
  }
}