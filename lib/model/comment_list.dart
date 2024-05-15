class CommentList {
  Paper? pager;
  List<CommentBean>? list;

  CommentList({this.pager, this.list});

  CommentList.fromJson(Map<String, dynamic> json) {
    if (json["pager"] is Paper) {
      pager = json["pager"];
    }

    if (json["list"] is List) {
      list = json["list"] == null
          ? null
          : (json["list"] as List).map((e) => CommentBean.fromJson(e)).toList();
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

class CommentBean {
  int? id;
  int? relId;
  String? relType;
  List<String>? at;
  String? comment;
  String? createdAt;
  int? replyCount;
  int? likeCount;
  Content? content;
  User? user;

  CommentBean({
    this.id,
    this.relId,
    this.relType,
    this.at,
    this.comment,
    this.content,
    this.createdAt,
    this.replyCount,
    this.likeCount,
    this.user,
  });

  CommentBean.fromJson(Map<String, dynamic> json) {
    if (json["id"] is int) {
      id = json["id"];
    }

    if (json["relId"] is int) {
      relId = json["relId"];
    }
    if (json["relType"] is String) {
      relType = json["relType"];
    }
    if (json["content"] is String) {
      content = json["content"];
    }
    if (json["createdAt"] is String) {
      createdAt = json["createdAt"];
    }
    if (json['content'] != null) {
      content = Content.fromJson(json['content']);
    }

    if (json["replyCount"] is int) {
      replyCount = json["replyCount"];
    }
    if (json["likeCount"] is int) {
      likeCount = json["likeCount"];
    }

    if (json["user"] is Map) {
      user = User.fromJson(json["user"]);
    }

    if (json["at"] is List) {
      at = json["at"] == null
          ? null
          : (json["at"] as List).map((e) => e.toString()).toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["relId"] = relId;
    _data["relType"] = relType;
    _data["at"] = at;
    _data["comment"] = comment;
    _data["createdAt"] = createdAt;
    _data["content"] = content;
    _data["replyCount"] = replyCount;
    _data["likeCount"] = likeCount;
    _data["user"] = user;
    return _data;
  }
}

class User {
  int? id;
  String? avatar;
  String? nickname;

  User({
    this.id,
    this.avatar,
    this.nickname,
  });

  User.fromJson(Map<String, dynamic> json) {
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

class Content {
  int? id;
  int? listId;
  int? categoryId;
  int? status;
  String? type;
  String? title;
  String? description;
  String? createdAt;
  String? updatedAt;
  String? cover;
  String? author;
  int? commentCount;
  int? favoriteCount;
  int? likeCount;
  int? duration;
  Content? content;

  Content({
    this.id,
    this.listId,
    this.categoryId,
    this.status,
    this.type,
    this.description,
    this.title,
    this.createdAt,
    this.updatedAt,
    this.commentCount,
    this.favoriteCount,
    this.likeCount,
    this.content,
    this.duration,
    this.cover,
    this.author,
  });

  Content.fromJson(Map<String, dynamic> json) {
    if (json["id"] is int) {
      id = json["id"];
    }

    if (json["listId"] is int) {
      listId = json["listId"];
    }
    if (json["categoryId"] is int) {
      categoryId = json["categoryId"];
    }
    if (json["status"] is int) {
      status = json["status"];
    }
    if (json["type"] is String) {
      type = json["type"];
    }
    if (json["author"] is String) {
      author = json["author"];
    }
    if (json["cover"] is String) {
      cover = json["cover"];
    }
    if (json["description"] is String) {
      description = json["description"];
    }
    if (json["title"] is String) {
      title = json["title"];
    }
    if (json["createdAt"] is String) {
      createdAt = json["createdAt"];
    }
    if (json["updatedAt"] is String) {
      updatedAt = json["updatedAt"];
    }
    if (json['content'] != null) {
      content = Content.fromJson(json['content']);
    }

    if (json["commentCount"] is int) {
      commentCount = json["commentCount"];
    }
    if (json["favoriteCount"] is int) {
      favoriteCount = json["favoriteCount"];
    }
    if (json["likeCount"] is int) {
      likeCount = json["likeCount"];
    }
    if (json["duration"] is int) {
      duration = json["duration"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["listId"] = listId;
    _data["categoryId"] = categoryId;
    _data["status"] = status;
    _data["type"] = type;
    _data["cover"] = cover;
    _data["author"] = author;
    _data["description"] = description;
    _data["title"] = title;
    _data["createdAt"] = createdAt;
    _data["updatedAt"] = updatedAt;
    _data["commentCount"] = commentCount;
    _data["favoriteCount"] = favoriteCount;
    _data["likeCount"] = likeCount;
    _data["duration"] = duration;
    _data["content"] = content;
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
