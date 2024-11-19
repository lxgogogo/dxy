import 'package:holdem/model/upload_file.dart';

import 'board_list.dart';

class CommentList {
  Paper? pager;
  List<CommentBean>? list;

  CommentList({this.pager, this.list});

  CommentList.fromJson(Map<String, dynamic> json) {
    if (json['pager'] != null) {
      pager = Paper.fromJson(json['pager']);
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
  int? resourceId;
  int? relId;
  String? relType;
  String? resourceType;
  BoardBean? thread;
  List<String>? at;
  List<UploadFile>? files;
  List<CommentBean>? replies;
  String? comment;
  DateTime? createdAt;
  int? replyCount;
  int? likeCount;
  Content? content;
  String? contentStr;
  User? user;
  bool? liked;
  CommentBean? parentComment;

  CommentBean({
    this.id,
    this.relId,
    this.relType,
    this.at,
    this.comment,
    this.content,
    this.thread,
    this.contentStr,
    this.createdAt,
    this.replyCount,
    this.likeCount,
    this.user,
    this.liked,
    this.replies,
    this.parentComment,
  });

  CommentBean.fromJson(Map<String, dynamic> json) {
    if (json["id"] is int) {
      id = json["id"];
    }

    if (json["resourceId"] is int) {
      resourceId = json["resourceId"];
    }

    if (json["comment"] is String) {
      comment = json["comment"];
    }
    if (json["relId"] is int) {
      relId = json["relId"];
    }
    if (json["relType"] is String) {
      relType = json["relType"];
    }
    if (json["resourceType"] is String) {
      resourceType = json["resourceType"];
    }
    // if (json["content"] is String) {
    //   content = json["content"];
    // }
    if (json["createdAt"] is String) {
      createdAt = DateTime.parse(json["createdAt"]).toLocal();
    }
    if (json['content'] != null && json['content'] is Map) {
      content = Content.fromJson(json['content']);
    }

    if (json["content"] is String) {
      contentStr = json["content"];
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
    if (json["liked"] is bool) {
      liked = json["liked"];
    }

    if (json["at"] is List) {
      at = json["at"] == null
          ? null
          : (json["at"] as List).map((e) => e.toString()).toList();
    }
    if (json["replies"] is List) {
      replies = (json["replies"] as List).map((e) => CommentBean.fromJson(e)).toList();
    }

    if (json["files"] is List) {
      files = (json["files"] as List).map((e) => UploadFile.fromJson(e)).toList();
    }

    if (json['thread'] != null) {
      thread = BoardBean.fromJson(json['thread']);
    }
    if (json['parentComment'] != null) {
      parentComment = CommentBean.fromJson(json['parentComment']);
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
    _data["contentStr"] = contentStr;
    _data["replyCount"] = replyCount;
    _data["likeCount"] = likeCount;
    _data["user"] = user;
    _data['liked'] = liked;
    _data['replies'] = replies;
    _data['thread'] = thread;
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

class Reply{
  int? id;
  String? content;
  DateTime? createdAt;
  User? user;

  Reply({
    this.id,
    this.content,
    this.createdAt,
    this.user,
  });

  Reply.fromJson(Map<String, dynamic> json) {
    if (json["id"] is int) {
      id = json["id"];
    }
    if (json["content"] is String) {
      content = json["content"];
    }
    if (json["createdAt"] is String) {
      createdAt = DateTime.parse(json["createdAt"]).toLocal();
    }
    if (json["user"] is Map) {
      user = User.fromJson(json["user"]);
    }
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
