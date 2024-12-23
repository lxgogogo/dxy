import 'dart:convert';

class TagModel {
  int? id;
  String? name;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? viewCount;
  int? commentCount;

  TagModel({
    this.id,
    this.name,
    this.createdAt,
    this.updatedAt,
    this.viewCount,
    this.commentCount,
  });

  factory TagModel.fromRawJson(String str) => TagModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TagModel.fromJson(Map<String, dynamic> json) => TagModel(
        id: json["id"],
        name: json["name"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        viewCount: json["viewCount"],
        commentCount: json["commentCount"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "viewCount": viewCount,
        "commentCount": commentCount,
      };
}
