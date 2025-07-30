import 'dart:convert';

CourseTopModel courseTopModelFromJson(String str) => CourseTopModel.fromJson(json.decode(str));

String courseTopModelToJson(CourseTopModel data) => json.encode(data.toJson());

class CourseTopModel {
  final int? courseGroupId;
  final int? winningDay; //连胜日
  final int? winningStatus; //连胜状态 1：置灰 2：冰冻 3：活跃
  final int? integral; //积分
  final int? courseTotal; //课程总数
  final int? courseCompleted; //已完成的课程数
  final int? courseRemaining; //剩余课程
  final int? knowledgeRemaining; //剩余知识
  int? practiseRemaining; //剩余练习
  final int? challengeRemaining; //剩余挑战
  final int? integralPunch;

  CourseTopModel({
    this.courseGroupId,
    this.winningDay,
    this.winningStatus,
    this.integral,
    this.courseTotal,
    this.courseCompleted,
    this.courseRemaining,
    this.knowledgeRemaining,
    this.practiseRemaining,
    this.challengeRemaining,
    this.integralPunch,
  });

  factory CourseTopModel.fromJson(Map<String, dynamic> json) => CourseTopModel(
        courseGroupId: json["courseGroupId"],
        winningDay: json["winningDay"],
        winningStatus: json["winningStatus"],
        integral: json["integral"],
        courseTotal: json["courseTotal"],
        courseCompleted: json["courseCompleted"],
        courseRemaining: json["courseRemaining"],
        knowledgeRemaining: json["knowledgeRemaining"],
        practiseRemaining: json["practiseRemaining"],
        challengeRemaining: json["challengeRemaining"],
        integralPunch: json["integralPunch"],
      );

  Map<String, dynamic> toJson() => {
        "courseGroupId": courseGroupId,
        "winningDay": winningDay,
        "winningStatus": winningStatus,
        "integral": integral,
        "courseTotal": courseTotal,
        "courseCompleted": courseCompleted,
        "courseRemaining": courseRemaining,
        "knowledgeRemaining": knowledgeRemaining,
        "practiseRemaining": practiseRemaining,
        "challengeRemaining": challengeRemaining,
        "integralPunch": integralPunch,
      };
}
