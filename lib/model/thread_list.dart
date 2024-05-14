import 'package:holdem/model/board_list.dart';

/// pager : {"total":1,"pageNum":0,"pageSize":10}
/// list : [{"id":2,"user":{"id":1,"nickname":"昵称","avatar":""},"board":{"id":1,"name":"测试板块"},"title":"titletitletitletitle 你好","tags":["测试"],"pics":["https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTQ0YBJwzYaHDpWjjGCkthYR8kBica2DXaqhZv-EwFZlg"],"commentCount":0,"favoriteCount":0,"likeCount":0,"liked":false,"favorited":false},{"id":1,"user":{"id":1,"nickname":"昵称","avatar":""},"board":{"id":1,"name":"测试板块"},"title":"title","tags":["测试"],"pics":["https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTQ0YBJwzYaHDpWjjGCkthYR8kBica2DXaqhZv-EwFZlg"],"commentCount":0,"favoriteCount":0,"likeCount":0,"liked":false,"favorited":false}]

class ThreadList {
  Paper? pager;
  List<ThreadListBean>? list;

  ThreadList({this.pager, this.list});

  ThreadList.fromJson(Map<String, dynamic> json) {
    if (json["pager"] is Paper) {
      pager = json["pager"];
    }

    if (json["list"] is List) {
      list = json["list"] == null
          ? null
          : (json["list"] as List)
              .map((e) => ThreadListBean.fromJson(e))
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

class ThreadListBean {
  int? id;
  String? createdAt;
  BoardBean? thread;
  ThreadListBean({this.id, this.createdAt, this.thread});

  ThreadListBean.fromJson(Map<String, dynamic> json) {
    if (json["id"] is int) {
      id = json["id"];
    }
    if (json["createdAt"] is String) {
      createdAt = json["createdAt"];
    }
    if (json['thread'] != null) {
      thread = BoardBean.fromJson(json['thread']);
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
