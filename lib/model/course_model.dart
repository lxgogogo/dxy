// To parse this JSON data, do
//
//     final courseModel = courseModelFromJson(jsonString);

import 'dart:convert';

CourseModel courseModelFromJson(String str) => CourseModel.fromJson(json.decode(str));

String courseModelToJson(CourseModel data) => json.encode(data.toJson());

class CourseModel {
  final int? id;
  final String? icon;
  final String? title;
  final String? des;
  final String? cover;
  final int? state;
  final int? knowledgeTotal;
  final int? knowledgeCompleted;
  final int? practiseTotal;
  final int? practiseCompleted;
  final int? challengeTotal;
  final int? challengeCompleted;

  CourseModel({
    this.id,
    this.icon,
    this.title,
    this.des,
    this.cover,
    this.state,
    this.knowledgeTotal,
    this.knowledgeCompleted,
    this.practiseTotal,
    this.practiseCompleted,
    this.challengeTotal,
    this.challengeCompleted,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) => CourseModel(
    id: json["id"],
    icon: json["icon"],
    title: json["title"],
    des: json["des"],
    cover: json["cover"],
    state: json["state"],
    knowledgeTotal: json["knowledgeTotal"],
    knowledgeCompleted: json["knowledgeCompleted"],
    practiseTotal: json["practiseTotal"],
    practiseCompleted: json["practiseCompleted"],
    challengeTotal: json["challengeTotal"],
    challengeCompleted: json["challengeCompleted"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "icon": icon,
    "title": title,
    "des": des,
    "cover": cover,
    "state": state,
    "knowledgeTotal": knowledgeTotal,
    "knowledgeCompleted": knowledgeCompleted,
    "practiseTotal": practiseTotal,
    "practiseCompleted": practiseCompleted,
    "challengeTotal": challengeTotal,
    "challengeCompleted": challengeCompleted,
  };
}
