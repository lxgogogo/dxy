class CourseBean {
  String? heading;
  List<CollectBean>? collects;

  CourseBean({this.heading,this.collects});

  CourseBean.fromJson(Map<String, dynamic> json) {
    if (json["heading"] is String) {
      heading = json["heading"];
    }

    if (json["collects"] is List) {
      collects = json["collects"] == null
          ? null
          : (json["collects"] as List)
              .map((e) => CollectBean.fromJson(e))
              .toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["heading"] = heading;
    if (collects != null) {
      _data["collects"] = collects?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class CollectBean {
  int? targetId;
  String? title;

  CollectBean({this.targetId, this.title});
  CollectBean.fromJson(Map<String, dynamic> json) {
    if (json["targetId"] is int) {
      targetId = json["targetId"];
    }
    if (json["title"] is String) {
      title = json["title"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["targetId"] = targetId;
    _data["title"] = title;
    return _data;
  }
}
