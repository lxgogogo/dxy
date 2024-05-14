class IndexCategory{
  int? id;
  String? name;
  String? alias;

  IndexCategory({this.id, this.name, this.alias});

  IndexCategory.fromJson(Map<String, dynamic> json) {
    if (json["id"] is int) {
      id = json["id"];
    }
    if (json["name"] is String) {
      name = json["name"];
    }
    if (json["alias"] is String) {
      alias = json["alias"];
    }
  }
}