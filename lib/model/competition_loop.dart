class CompetionLoopBean {
  int? id;
  String? title;

  CompetionLoopBean({this.id,this.title});

  CompetionLoopBean.fromJson(Map<String, dynamic> json) {
    if (json["title"] is String) {
      title = json["title"];
    }

    if (json["id"] is int) {
      id = json["id"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["title"] = title;
    return _data;
  }
}