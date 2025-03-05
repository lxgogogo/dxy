// To parse this JSON data, do
//
//     final video = videoFromMap(jsonString);

import 'dart:convert';

Video videoFromMap(String str) => Video.fromMap(json.decode(str));

String videoToMap(Video data) => json.encode(data.toMap());

class Video {
  final int? code;
  final String? message;
  final List<VideoBean>? videoBean;
  final String? traceId;

  Video({
    this.code,
    this.message,
    this.videoBean,
    this.traceId,
  });

  Video copyWith({
    int? code,
    String? message,
    List<VideoBean>? videoBean,
    String? traceId,
  }) =>
      Video(
        code: code ?? this.code,
        message: message ?? this.message,
        videoBean: videoBean ?? this.videoBean,
        traceId: traceId ?? this.traceId,
      );

  factory Video.fromMap(Map<String, dynamic> json) => Video(
    code: json["code"],
    message: json["message"],
    videoBean: json["data"] == null ? [] : List<VideoBean>.from(json["data"]!.map((x) => VideoBean.fromMap(x))),
    traceId: json["traceId"],
  );

  Map<String, dynamic> toMap() => {
    "code": code,
    "message": message,
    "videoBean": videoBean == null ? [] : List<dynamic>.from(videoBean!.map((x) => x.toMap())),
    "traceId": traceId,
  };
}

class VideoBean {
  final int? id;
  final String? title;
  final String? description;
  final String? cover;
  final double? popularCount;
  final String? type;
  final DateTime? createdAt;

  VideoBean({
    this.id,
    this.title,
    this.description,
    this.cover,
    this.popularCount,
    this.type,
    this.createdAt,
  });

  VideoBean copyWith({
    int? id,
    String? title,
    String? description,
    String? cover,
    double? popularCount,
    String? type,
    DateTime? createdAt,
  }) =>
      VideoBean(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        cover: cover ?? this.cover,
        popularCount: popularCount ?? this.popularCount,
        type: type ?? this.type,
        createdAt: createdAt ?? this.createdAt,
      );

  factory VideoBean.fromMap(Map<String, dynamic> json) => VideoBean(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    cover: json["cover"],
    popularCount: json["popularCount"]?.toDouble(),
    type: json["type"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "title": title,
    "description": description,
    "cover": cover,
    "popularCount": popularCount,
    "type": type,
    "createdAt": createdAt?.toIso8601String(),
  };
}
