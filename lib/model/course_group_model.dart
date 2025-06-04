// To parse this JSON data, do
//
//     final courseGroupModel = courseGroupModelFromJson(jsonString);

import 'dart:convert';

CourseGroupModel courseGroupModelFromJson(String str) => CourseGroupModel.fromJson(json.decode(str));

String courseGroupModelToJson(CourseGroupModel data) => json.encode(data.toJson());

class CourseGroupModel {
  final String? label;
  final Value? value;

  CourseGroupModel({
    this.label,
    this.value,
  });

  factory CourseGroupModel.fromJson(Map<String, dynamic> json) => CourseGroupModel(
    label: json["label"],
    value: json["value"] == null ? null : Value.fromJson(json["value"]),
  );

  Map<String, dynamic> toJson() => {
    "label": label,
    "value": value?.toJson(),
  };
}

class Value {
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? id;
  final int? sort;
  final String? icon;
  final String? des;
  final int? status;

  Value({
    this.createdAt,
    this.updatedAt,
    this.id,
    this.sort,
    this.icon,
    this.des,
    this.status,
  });

  factory Value.fromJson(Map<String, dynamic> json) => Value(
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    id: json["id"],
    sort: json["sort"],
    icon: json["icon"],
    des: json["des"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "id": id,
    "sort": sort,
    "icon": icon,
    "des": des,
    "status": status,
  };
}
