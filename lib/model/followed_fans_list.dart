import 'package:holdem/model/board_info.dart';
import 'package:holdem/model/upload_file.dart';
import 'package:holdem/model/user.dart';

/// pager : {"total":1,"pageNum":0,"pageSize":10}
/// list : [{"id":2,"user":{"id":1,"nickname":"昵称","avatar":""},"board":{"id":1,"name":"测试板块"},"title":"titletitletitletitle 你好","tags":["测试"],"pics":["https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTQ0YBJwzYaHDpWjjGCkthYR8kBica2DXaqhZv-EwFZlg"],"commentCount":0,"favoriteCount":0,"likeCount":0,"liked":false,"favorited":false},{"id":1,"user":{"id":1,"nickname":"昵称","avatar":""},"board":{"id":1,"name":"测试板块"},"title":"title","tags":["测试"],"pics":["https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTQ0YBJwzYaHDpWjjGCkthYR8kBica2DXaqhZv-EwFZlg"],"commentCount":0,"favoriteCount":0,"likeCount":0,"liked":false,"favorited":false}]

class FollowedFansList {
  Paper? pager;
  List<FollowedFansBean>? list;

  FollowedFansList({this.pager, this.list});

  FollowedFansList.fromJson(Map<String, dynamic> json) {
    if (json["pager"] is Paper) {
      pager = json["pager"];
    }

    if (json["list"] is List) {
      list = json["list"] == null
          ? null
          : (json["list"] as List)
              .map((e) => FollowedFansBean.fromJson(e))
              .toList();
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

class FollowedFansBean {
  int? id;
  String? createdAt;
  ThreadBean? thread;
  FollowedFansBean({this.id, this.createdAt, this.thread});

  FollowedFansBean.fromJson(Map<String, dynamic> json) {
    if (json["id"] is int) {
      id = json["id"];
    }
    if (json["createdAt"] is String) {
      createdAt = json["createdAt"];
    }
    if (json['thread'] != null) {
      thread = ThreadBean.fromJson(json['thread']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["createdAt"] = createdAt;
    _data["thread"] = thread;

    return _data;
  }
}

class ThreadBean {
  int? id;
  UserProfile? user;
  BoardInfo? board;
  String? title;
  String? content;
  String? createdAt;
  int? commentCount;
  int? favoriteCount;
  int? likeCount;
  bool? liked;
  bool? favorited;
  List<String>? tags;
  List<String>? pics;
  List<UploadFile>? files;

  ThreadBean(
      {this.id,
      this.user,
      this.board,
      this.title,
      this.content,
      this.createdAt,
      this.commentCount,
      this.favoriteCount,
      this.likeCount,
      this.liked,
      this.favorited,
      this.tags,
      this.pics,
      this.files});

  ThreadBean.fromJson(Map<String, dynamic> json) {
    if (json["id"] is int) {
      id = json["id"];
    }
    if (json["title"] is String) {
      title = json["title"];
    }
    if (json["content"] is String) {
      content = json["content"];
    }
    if (json["createdAt"] is String) {
      createdAt = json["createdAt"];
    }
    if (json['user'] != null) {
      user = UserProfile.fromJson(json['user']);
    }
    if (json['board'] != null) {
      board = BoardInfo.fromJson(json['user']);
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
    if (json["liked"] is bool) {
      liked = json["liked"];
    }
    if (json["favorited"] is bool) {
      favorited = json["favorited"];
    }
    if (json["tags"] is List) {
      tags = json["tags"] == null
          ? null
          : (json["tags"] as List).map((e) => e.toString()).toList();
    }

    if (json["files"] is List) {
      files = json["files"] == null
          ? null
          : (json["files"] as List).map((e) => UploadFile.fromJson(e)).toList();
    }
    if (json["pics"] is List) {
      pics = json["pics"] == null
          ? null
          : (json["pics"] as List).map((e) => e.toString()).toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["user"] = user;
    _data["board"] = board;
    _data["title"] = title;
    _data["content"] = content;
    _data["commentCount"] = commentCount;
    _data["favoriteCount"] = favoriteCount;
    _data["likeCount"] = likeCount;
    _data["liked"] = liked;
    _data["tags"] = tags;
    _data["files"] = files;
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
