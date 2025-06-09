// To parse this JSON data, do
//
//     final coursePunchModel = coursePunchModelFromJson(jsonString);

import 'dart:convert';

CoursePunchModel coursePunchModelFromJson(String str) => CoursePunchModel.fromJson(json.decode(str));

String coursePunchModelToJson(CoursePunchModel data) => json.encode(data.toJson());

class CoursePunchModel {
  final int? winnerDay;
  final String? tipText;
  final List<int>? target;
  final int? punchTotal;
  final int? integralTotal;
  final List<PractiseList>? practiseList;

  CoursePunchModel({
    this.winnerDay,
    this.tipText,
    this.target,
    this.punchTotal,
    this.integralTotal,
    this.practiseList,
  });

  factory CoursePunchModel.fromJson(Map<String, dynamic> json) => CoursePunchModel(
    winnerDay: json["winnerDay"],
    tipText: json["tipText"],
    target: json["target"] == null ? [] : List<int>.from(json["target"]!.map((x) => x)),
    punchTotal: json["punchTotal"],
    integralTotal: json["integralTotal"],
    practiseList: json["practiseList"] == null ? [] : List<PractiseList>.from(json["practiseList"]!.map((x) => PractiseList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "winnerDay": winnerDay,
    "tipText": tipText,
    "target": target == null ? [] : List<dynamic>.from(target!.map((x) => x)),
    "punchTotal": punchTotal,
    "integralTotal": integralTotal,
    "practiseList": practiseList == null ? [] : List<dynamic>.from(practiseList!.map((x) => x.toJson())),
  };
}

class PractiseList {
  final int? type;
  final DateTime? punchDate;

  PractiseList({
    this.type,
    this.punchDate,
  });

  factory PractiseList.fromJson(Map<String, dynamic> json) => PractiseList(
    type: json["type"],
    punchDate: json["punchDate"] == null ? null : DateTime.parse(json["punchDate"]),
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "punchDate": "${punchDate!.year.toString().padLeft(4, '0')}-${punchDate!.month.toString().padLeft(2, '0')}-${punchDate!.day.toString().padLeft(2, '0')}",
  };
}
