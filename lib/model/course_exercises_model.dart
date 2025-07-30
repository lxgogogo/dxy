
import 'dart:convert';

class CourseExerciseAllModel {

  int? id;
  int? total;
  int? completed;
  int? integral;
  List<CourseExerciseModel>? practiseList;

  CourseExerciseAllModel({
    this.id,
    this.total,
    this.completed,
    this.integral,
    this.practiseList,
  });

  CourseExerciseAllModel.fromJson(Map<String, dynamic> json) {
    if (json["id"] is int) {
      id = json["id"];
    }
    if (json["total"] is int) {
      total = json["total"];
    }
    if (json["completed"] is int) {
      completed = json["completed"];
    }
    if (json["integral"] is int) {
      integral = json["integral"];
    }
    if (json['practiseList'] is List) {
      practiseList = (json["practiseList"] as List).map((e) => CourseExerciseModel.fromJson(e)).toList();
    }

  }

}

class CourseExerciseModel {

  int? id;
  String? title;
  String? content;
  String? answer;
  bool? select;
  bool? completed;
  int? integral;
  List<CourseExerciseAnswerModel>? options;

  CourseExerciseModel({
    this.id,
    this.title,
    this.content,
    this.options,
    this.answer,
    this.select,
    this.completed,
    this.integral
  });

  CourseExerciseModel.fromJson(Map<String, dynamic> map) {
    if (map["id"] is int) {
      id = map["id"];
    }
    if (map["integral"] is int) {
      integral = map["integral"];
    }
    if (map["title"] is String) {
      title = map["title"];
    }
    if (map["content"] is String) {
      content = map["content"];
    }
    if (map["answer"] is String) {
      answer = map["answer"];
    }
    if (map['options'] is String) {
      final data = json.decode(map['options']);
      options = (data as List).map((e) => CourseExerciseAnswerModel.fromJson(e)).toList();
    }

  }
}

class CourseExerciseAnswerModel {

  String? id;
  String? title;
  bool? select;
  bool? submit;
  bool? isCorrect;
  bool? editing;


  CourseExerciseAnswerModel({
    this.id,
    this.title,
    this.submit,
    this.select,
    this.isCorrect,
    this.editing
  });

  CourseExerciseAnswerModel.fromJson(Map<String, dynamic> json) {
    if (json["id"] is String) {
      id = json["id"];
    }
    if (json["innerText"] is String) {
      title = json["innerText"];
    }
    if (json["editing"] is bool) {
      isCorrect = json["editing"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["title"] = title;
    _data["isCorrect"] = isCorrect;
    return _data;
  }
}

class CourseAnswerModel {
  int? id;
  int? status;
  bool? answer;
  String? answerStr;
  String? text;
  String? pairsText;
  int? pairsIntegral;
  int? integral;
  int? integralTotal;

  CourseAnswerModel({
    this.id,
    this.status,
    this.answer,
    this.answerStr,
    this.text,
    this.pairsText,
    this.pairsIntegral,
    this.integral,
    this.integralTotal
  });

  CourseAnswerModel.fromJson(Map<String, dynamic> json) {
    if (json["id"] is int) {
      id = json["id"];
    }
    if (json["status"] is int) {
      status = json["status"];
    }
    if (json["pairsIntegral"] is int) {
      pairsIntegral = json["pairsIntegral"];
    }
    if (json["integral"] is int) {
      integral = json["integral"];
    }
    if (json["integralTotal"] is int) {
      integralTotal = json["integralTotal"];
    }
    if (json["answer"] is bool) {
      answer = json["answer"];
    }
    if (json["answerStr"] is String) {
      answerStr = json["answerStr"];
    }
    if (json["text"] is String) {
      text = json["text"];
    }
    if (json["pairsText"] is String) {
      pairsText = json["pairsText"];
    }
  }
}