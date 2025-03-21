import 'dart:convert';

class MessageBadgeModel {
  int? total;
  int? at;
  int? like;
  int? comment;
  int? favorite;

  MessageBadgeModel({
    this.total,
    this.at,
    this.like,
    this.comment,
    this.favorite,
  });

  factory MessageBadgeModel.fromRawJson(String str) => MessageBadgeModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MessageBadgeModel.fromJson(Map<String, dynamic> json) => MessageBadgeModel(
    total: json["total"],
    at: json["at"],
    like: json["like"],
    comment: json["comment"],
    favorite: json["favorite"],
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "at": at,
    "like": like,
    "comment": comment,
    "favorite": favorite,
  };
}
