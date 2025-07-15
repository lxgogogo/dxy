import 'dart:convert';

class RecommendVideoModel {
  final int? id;
  final String? title;
  final String? cover;

  RecommendVideoModel({
    this.id,
    this.title,
    this.cover,
  });

  RecommendVideoModel copyWith({
    int? id,
    String? title,
    String? cover,
  }) =>
      RecommendVideoModel(
        id: id ?? this.id,
        title: title ?? this.title,
        cover: cover ?? this.cover,
      );

  factory RecommendVideoModel.fromRawJson(String str) => RecommendVideoModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RecommendVideoModel.fromJson(Map<String, dynamic> json) => RecommendVideoModel(
    id: json["id"],
    title: json["title"],
    cover: json["cover"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "cover": cover,
  };
}
