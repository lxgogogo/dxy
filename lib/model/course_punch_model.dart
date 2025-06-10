import 'dart:convert';

class CoursePunchModel {
  final int? winnerDay;
  final String? tipText;
  final List<int>? target;
  final int? punchTotal;
  final int? integralTotal;
  final int? status;
  final List<PractiseList>? practiseList;

  CoursePunchModel({
    this.winnerDay,
    this.tipText,
    this.target,
    this.punchTotal,
    this.integralTotal,
    this.status,
    this.practiseList,
  });

  factory CoursePunchModel.fromJson(Map<String, dynamic> json) => CoursePunchModel(
        winnerDay: json["winnerDay"],
        // winnerDay: 5,
        tipText: json["tipText"],
        target: json["target"] == null ? [] : List<int>.from(json["target"]!.map((x) => x)),
        // target: [1, 7, 14, 30, 50],
        punchTotal: json["punchTotal"],
        integralTotal: json["integralTotal"],
        status: json["status"],
        practiseList: json["practiseList"] == null ? [] : List<PractiseList>.from(json["practiseList"]!.map((x) => PractiseList.fromJson(x))),
        // practiseList: List<PractiseList>.from([
        //   {"type": 1, "punchDate": "2025-06-14"},
        //   {"type": 1, "punchDate": "2025-06-15"},
        //   {"type": 2, "punchDate": "2025-06-16"},
        //   {"type": 1, "punchDate": "2025-06-17"},
        //   {"type": 1, "punchDate": "2025-06-18"},
        //   {"type": 1, "punchDate": "2025-06-19"},
        //   {"type": 1, "punchDate": "2025-06-20"},
        // ].map((x) => PractiseList.fromJson(x))),
      );
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
        punchDate: json["punchDate"] == null ? null : DateTime.tryParse(json["punchDate"])?.toLocal(),
      );
}
