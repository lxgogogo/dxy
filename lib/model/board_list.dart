import 'package:holdem/model/article.dart';
import 'package:holdem/model/board_info.dart';
import 'package:holdem/model/tag_model.dart';
import 'package:holdem/model/upload_file.dart';
import 'package:holdem/model/user.dart';
import 'package:holdem/utils/html_parse_util.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

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
      list = json["list"] == null ? null : (json["list"] as List).map((e) => BoardBean.fromJson(e)).toList();
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
  int? viewCount;
  bool? liked;
  bool? favorited;
  List<TagModel>? tagList;
  List<String>? sign;
  List<String>? pics;
  List<UploadFile>? files;
  String? relType;
  String? cover;
  String? comment;

  ///观看引流广告开关 0:否  1:是
  int? advertiseStatus;

  ///观看引流广告网址
  String? advertiseUrl;

  ///观看引流广告图
  String? advertiseImage;

  BoardBean({
    this.id,
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
    this.viewCount,
    this.liked,
    this.favorited,
    this.tagList,
    this.sign,
    this.pics,
    this.files,
    this.relType,
    this.contentBean,
    this.cover,
    this.comment,
    this.advertiseStatus,
    this.advertiseUrl,
    this.advertiseImage,
  });

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
      if (pureText?.isNotEmpty != true) {
        pureText = HtmlParseUtil.of.pureText(content);
      }
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
      board = BoardInfo.fromJson(json['board']);
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
    if (json["viewCount"] is int) {
      viewCount = json["viewCount"];
    }
    if (json["liked"] is bool) {
      liked = json["liked"];
    }
    if (json["favorited"] is bool) {
      favorited = json["favorited"];
    }
    if (json["tagList"] is List) {
      tagList = json["tagList"] == null ? null : (json["tagList"] as List).map((e) => TagModel.fromJson(e)).toList();
    }
    if (json["sign"] is List) {
      sign = json["sign"] == null ? null : (json["sign"] as List).map((e) => e.toString()).toList();
    }

    if (json["files"] is List) {
      files = json["files"] == null ? null : (json["files"] as List).map((e) => UploadFile.fromJson(e)).toList();
    }
    if (json["pics"] is List) {
      pics = json["pics"] == null ? null : (json["pics"] as List).map((e) => e.toString()).toList();
    }

    if (json["advertiseStatus"] is int) {
      advertiseStatus = json["advertiseStatus"];
    }

    if (json["advertiseUrl"] is String) {
      advertiseUrl = json["advertiseUrl"];
    }

    if (json["advertiseImage"] is String) {
      advertiseImage = json["advertiseImage"];
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
    _data["viewCount"] = viewCount;
    _data["liked"] = liked;
    _data["tagList"] = tagList;
    _data["files"] = files;
    _data["relType"] = relType;
    _data["comment"] = comment;
    _data["contentBean"] = contentBean;
    _data["advertiseStatus"] = advertiseStatus;
    _data["advertiseUrl"] = advertiseUrl;
    _data["advertiseImage"] = advertiseImage;
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
