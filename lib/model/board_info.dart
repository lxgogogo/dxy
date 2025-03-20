class BoardInfo {
  int? id;
  String? name;
  int? type;

  BoardInfo({this.id, this.name, this.type});

  BoardInfo.fromJson(Map<String, dynamic> json) {
    if (json["id"] is int) {
      id = json["id"];
    }
    if (json["name"] is String) {
      name = json["name"];
    }
    if (json["type"] is int) {
      type = json["type"];
    }

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["name"] = name;
    _data["type"] = type;
    return _data;
  }
}
