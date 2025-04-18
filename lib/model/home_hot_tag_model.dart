
class HomeHotTagModel {

  String? name;
  int? id;
  int? viewCount;
  int? commentCount;
  bool? select;


  HomeHotTagModel({
    this.name,
    this.id,
    this.viewCount,
    this.commentCount,
    this.select});

  HomeHotTagModel.fromJson(Map<String, dynamic> json) {
    if (json["id"] is int) {
      id = json["id"];
    }
    if (json["viewCount"] is int) {
      viewCount = json["viewCount"];
    }
    if (json["commentCount"] is int) {
      commentCount = json["commentCount"];
    }
    if (json["name"] is String) {
      name = json["name"];
    }

  }
}