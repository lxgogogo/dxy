// To parse this JSON data, do
//
//     final courseModel = courseModelFromJson(jsonString);

import 'dart:convert';

CourseModel courseModelFromJson(String str) =>
    CourseModel.fromJson(json.decode(str));

String courseModelToJson(CourseModel data) => json.encode(data.toJson());

class CourseModel {
  int? id;
  final int? courseId;
  final String? icon;
  final String? title;
  final String? des;
  final String? cover;
  int? status;
  final int? knowledgeTotal;
  final int? knowledgeCompleted;
  final int? practiseTotal;
  final int? practiseCompleted;
  final int? challengeTotal;
  final int? challengeCompleted;
  final int? type;
  String? infoTitle;
  String? contentType;
  int? contentId;
  final int? subContentId;
  final int? total;
  int? completed;
  final int? integral;
  final List<ChallengeIndexDtoList>? challengeIndexDtoList;
  final CourseModel? knowledge;
  final CourseModel? practise;
  final CourseModel? challenge;
  List<KnowledgeIndexDtoList>? knowledgeIndexDtoList;
  List<KnowledgeIndexDtoList>? practiseIndexDtoList;

  double get progress {
    if ((total ?? 0) == 0) return 0;
    return (completed ?? 0) / (total ?? 0);
  }

  CourseModel(
      {this.id,
      this.courseId,
      this.icon,
      this.title,
      this.des,
      this.cover,
      this.status,
      this.knowledgeTotal,
      this.knowledgeCompleted,
      this.practiseTotal,
      this.practiseCompleted,
      this.challengeTotal,
      this.challengeCompleted,
      this.type,
      this.infoTitle,
      this.contentType,
      this.contentId,
      this.subContentId,
      this.total,
      this.completed,
      this.integral,
      this.challengeIndexDtoList,
      this.knowledge,
      this.practise,
      this.challenge,
      this.knowledgeIndexDtoList,
      this.practiseIndexDtoList});

  factory CourseModel.fromJson(Map<String, dynamic> json) => CourseModel(
        id: json["id"],
        courseId: json["courseId"],
        icon: json["icon"],
        title: json["title"],
        des: json["des"],
        cover: json["cover"],
        status: json["status"],
        knowledgeTotal: json["knowledgeTotal"],
        knowledgeCompleted: json["knowledgeCompleted"],
        practiseTotal: json["practiseTotal"],
        practiseCompleted: json["practiseCompleted"],
        challengeTotal: json["challengeTotal"],
        challengeCompleted: json["challengeCompleted"],
        type: json["type"],
        infoTitle: json["infoTitle"],
        contentType: json["contentType"],
        contentId: json["contentId"],
        subContentId: json["subContentId"],
        total: json["total"],
        completed: json["completed"],
        integral: json["integral"],
        challengeIndexDtoList: json["challengeIndexDtoList"] == null
            ? []
            : List<ChallengeIndexDtoList>.from(json["challengeIndexDtoList"]!
                .map((x) => ChallengeIndexDtoList.fromJson(x))),
        knowledgeIndexDtoList: json["knowledgeIndexDtoList"] == null
            ? []
            : List<KnowledgeIndexDtoList>.from(json["knowledgeIndexDtoList"]!
                .map((x) => KnowledgeIndexDtoList.fromJson(x))),
        practiseIndexDtoList: json["practiseIndexDtoList"] == null
            ? []
            : List<KnowledgeIndexDtoList>.from(json["practiseIndexDtoList"]!
                .map((x) => KnowledgeIndexDtoList.fromJson(x))),
        knowledge: json["knowledge"] == null
            ? null
            : CourseModel.fromJson(json["knowledge"]),
        practise: json["practise"] == null
            ? null
            : CourseModel.fromJson(json["practise"]),
        challenge: json["challenge"] == null
            ? null
            : CourseModel.fromJson(json["challenge"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "courseId": courseId,
        "icon": icon,
        "title": title,
        "des": des,
        "cover": cover,
        "state": status,
        "knowledgeTotal": knowledgeTotal,
        "knowledgeCompleted": knowledgeCompleted,
        "practiseTotal": practiseTotal,
        "practiseCompleted": practiseCompleted,
        "challengeTotal": challengeTotal,
        "challengeCompleted": challengeCompleted,
        "type": type,
        "infoTitle": infoTitle,
        "contentType": contentType,
        "contentId": contentId,
        "subContentId": subContentId,
        "total": total,
        "completed": completed,
        "integral": integral,
        "challengeIndexDtoList": challengeIndexDtoList == null
            ? []
            : List<dynamic>.from(challengeIndexDtoList!.map((x) => x.toJson())),
        "knowledgeIndexDtoList": knowledgeIndexDtoList == null
            ? []
            : List<dynamic>.from(knowledgeIndexDtoList!.map((x) => x.toJson())),
        "practiseIndexDtoList": practiseIndexDtoList == null
            ? []
            : List<dynamic>.from(practiseIndexDtoList!.map((x) => x.toJson())),
        "knowledge": knowledge?.toJson(),
        "practise": practise?.toJson(),
        "challenge": challenge?.toJson(),
      };
}

class KnowledgeIndexDtoList {
  final int? id;
  int? contentId;
  final String? title;
  final String? contentType;
  bool? select;

  KnowledgeIndexDtoList(
      {this.id, this.contentId, this.title, this.contentType, this.select});

  factory KnowledgeIndexDtoList.fromJson(Map<String, dynamic> json) =>
      KnowledgeIndexDtoList(
        id: json["id"],
        contentId: json["contentId"],
        contentType: json["contentType"],
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "contentId": contentId,
        "contentType": contentType,
        "title": title
      };
}

class ChallengeIndexDtoList {
  final int? id;
  int? status;
  final String? content;
  final int? integral;
  final String? desc;

  ChallengeIndexDtoList({
    this.id,
    this.status,
    this.content,
    this.integral,
    this.desc,
  });

  factory ChallengeIndexDtoList.fromJson(Map<String, dynamic> json) =>
      ChallengeIndexDtoList(
        id: json["id"],
        status: json["status"],
        content: json["content"],
        integral: json["integral"],
        desc: json['desc'],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "status": status,
        "content": content,
        "integral": integral,
        "desc": desc,
      };
}
