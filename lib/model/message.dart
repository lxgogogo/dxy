import 'article.dart';
import 'board_list.dart';

class MessageList {
  Paper? pager;
  List<MessageBean>? list;

  MessageList({this.pager, this.list});

  MessageList.fromJson(Map<String, dynamic> json) {
    if (json['pager'] != null) {
      pager = Paper.fromJson(json['pager']);
    }

    if (json["list"] is List) {
      list = json["list"] == null
          ? null
          : (json["list"] as List).map((e) => MessageBean.fromJson(e)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["pager"] = pager;
    if (list != null) {
      _data["list"] = list?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class MessageBean {
  int? id;
  String? type;
  String? quote;
  String? resourceType;
  int? jumpId;
  String? jumpType;
  String? itemType;
  int? itemId;
  String? description;
  DateTime? createdAt;
  MessageUser? fromUser;
  MessageUser? contentUser;
  MessageContent? content;
  ArticleBean? contentData;
  BoardBean? threadData;

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
    if (json["resourceType"] is String) {
      resourceType = json["resourceType"];
    }
    if (json["jumpId"] is int) {
      jumpId = json["jumpId"];
    }
    if (json["jumpType"] is String) {
      jumpType = json["jumpType"];
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
      createdAt = DateTime.parse(json["createdAt"]).toLocal();
    }
    if (json["fromUser"] is Map) {
      fromUser = MessageUser.fromJson(json["fromUser"]);
    }
    if (json["contentUser"] is Map) {
      contentUser = MessageUser.fromJson(json["contentUser"]);
    }
    if (json["content"] is Map) {
      content = MessageContent.fromJson(json["content"]);
    }
    if (json['contentData'] != null) {
      contentData = ArticleBean.fromJson(json['contentData']);
    }
    if (json['threadData'] != null) {
      threadData = BoardBean.fromJson(json['threadData']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["type"] = type;
    _data["quote"] = quote;
    _data["resourceType"] = resourceType;
    _data["jumpId"] = jumpId;
    _data["itemType"] = itemType;
    _data["itemId"] = itemId;
    _data["description"] = description;
    _data["createdAt"] = createdAt;
    _data["fromUser"] = fromUser?.toJson();
    _data["content"] = content?.toJson();
    _data["contentData"] = contentData?.toJson();
    return _data;
  }
}

class MessageUser {
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

class MessageContent {
  int? commentCount;
  int? favoriteCount;
  int? likeCount;
  String? title;

  MessageContent.fromJson(Map<String, dynamic> json) {
    if (json["commentCount"] is int) {
      commentCount = json["commentCount"];
    }
    if (json["favoriteCount"] is int) {
      favoriteCount = json["favoriteCount"];
    }
    if (json["likeCount"] is int) {
      likeCount = json["likeCount"];
    }
    if (json["title"] is String) {
      title = json["title"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["commentCount"] = commentCount;
    _data["favoriteCount"] = favoriteCount;
    _data["likeCount"] = likeCount;
    _data["title"] = title;
    return _data;
  }
}
class Paper {
  int? total;
  int? pageNum;
  int? pageSize;

  Paper({this.total, this.pageNum, this.pageSize});

  Paper.fromJson(Map<String, dynamic> json) {
    if (json["total"] is int) {
      total = json["total"];
    }

    if (json["pageNum"] is int) {
      pageNum = json["pageNum"];
    }
    if (json["pageSize"] is int) {
      pageSize = json["pageSize"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["total"] = total;
    _data["pageNum"] = pageNum;
    _data["pageSize"] = pageSize;
    return _data;
  }
}
