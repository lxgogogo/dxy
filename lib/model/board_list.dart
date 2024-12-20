import 'package:holdem/model/article.dart';
import 'package:holdem/model/board_info.dart';
import 'package:holdem/model/upload_file.dart';
import 'package:holdem/model/user.dart';

/// pager : {"total":1,"pageNum":0,"pageSize":10}
/// list : [{"id":2,"user":{"id":1,"nickname":"昵称","avatar":""},"board":{"id":1,"name":"测试板块"},"title":"titletitletitletitle 你好","tags":["测试"],"pics":["https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTQ0YBJwzYaHDpWjjGCkthYR8kBica2DXaqhZv-EwFZlg"],"commentCount":0,"favoriteCount":0,"likeCount":0,"liked":false,"favorited":false},{"id":1,"user":{"id":1,"nickname":"昵称","avatar":""},"board":{"id":1,"name":"测试板块"},"title":"title","tags":["测试"],"pics":["https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTQ0YBJwzYaHDpWjjGCkthYR8kBica2DXaqhZv-EwFZlg"],"commentCount":0,"favoriteCount":0,"likeCount":0,"liked":false,"favorited":false}]

class BoardList {
  Paper? pager;
  List<BoardBean>? list;

  BoardList({this.pager, this.list});

  BoardList.fromJson(Map<String, dynamic> json) {
    if (json['pager'] != null) {
      pager = Paper.fromJson(json['pager']);
    }

    if (json["list"] is List) {
      list = json["list"] == null
          ? null
          : (json["list"] as List).map((e) => BoardBean.fromJson(e)).toList();
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

class BoardBean {
  int? id;
  int? orignalId;
  UserProfile? user;
  BoardInfo? board;
  String? title;
  String? content;
  String? pureText;
  ArticleBean? contentBean;
  DateTime? createdAt;
  int? commentCount;
  int? favoriteCount;
  int? likeCount;
  int? shareCount;
  bool? liked;
  bool? favorited;
  List<String>? tags;
  List<String>? sign;
  List<String>? pics;
  List<UploadFile>? files;
  String? relType;
  String? cover;
  String? comment;

  BoardBean(
      {this.id,
      this.orignalId,
      this.user,
      this.board,
      this.title,
      this.content,
      this.pureText,
      this.createdAt,
      this.commentCount,
      this.favoriteCount,
      this.likeCount,
      this.shareCount,
      this.liked,
      this.favorited,
      this.tags,
      this.sign,
      this.pics,
      this.files,
      this.relType,
      this.contentBean,
      this.cover,
      this.comment});

  BoardBean.fromJson(Map<String, dynamic> json) {
    if (json["id"] is int) {
      id = json["id"];
    }
    if (json["title"] is String) {
      title = json["title"];
    }
    if (json["comment"] is String) {
      comment = json["comment"];
    }
    if (json["content"] is String) {
      content = json["content"];
    }
    if (json["pureText"] is String) {
      pureText = json["pureText"];
    }
    if (json["content"] != null && json["content"] is! String) {
      contentBean = ArticleBean.fromJson(json);
    }
    if (json["relType"] is String) {
      relType = json["relType"];
    }
    if (json["createdAt"] is String) {
      createdAt = DateTime.parse(json["createdAt"]).toLocal();
    }
    if (json["cover"] is String) {
      cover = json["cover"];
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
    if (json["shareCount"] is int) {
      shareCount = json["shareCount"];
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
    if (json["sign"] is List) {
      sign = json["sign"] == null
          ? null
          : (json["sign"] as List).map((e) => e.toString()).toList();
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
    _data["shareCount"] = shareCount;
    _data["liked"] = liked;
    _data["tags"] = tags;
    _data["files"] = files;
    _data["relType"] = relType;
    _data["comment"] = comment;
    _data["contentBean"] = contentBean;
    return _data;
  }
}

// class BoardContentBean{
//   String? cover;
//   String? title;

//   BoardContentBean.fromJson(Map<String, dynamic> json) {
//     if (json["cover"] is String) {
//       cover = json["cover"];
//     }
//     if (json["createdAt"] is String) {
//       title = json["title"];
//     }
//   }
// }

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
