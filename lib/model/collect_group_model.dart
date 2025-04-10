
class CollectGroupModel {
  String? name;
  DateTime? createdat;
  int? id;
  int? count;

  CollectGroupModel({
    this.id,
    this.name,
    this.count,
    this.createdat
  });

  factory CollectGroupModel.fromJson(Map<String, dynamic> json) {
    DateTime? _createdat;
    String atStr = json["createdat"] ?? '';
    if (atStr.isNotEmpty) {
      _createdat = DateTime.parse(atStr).toLocal();
    }
    return CollectGroupModel(
      name: json["name"],
      count: json["count"],
      createdat: _createdat,
      id: json["id"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "createdat": createdat,
    "count": count,
    "name": name,
  };
}