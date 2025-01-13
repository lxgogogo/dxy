import 'dart:convert';

class ReportTypeModel {
  String? label;
  String? value;

  ReportTypeModel({
    this.label,
    this.value,
  });

  factory ReportTypeModel.fromRawJson(String str) => ReportTypeModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ReportTypeModel.fromJson(Map<dynamic, dynamic> json) => ReportTypeModel(
    label: json["label"],
    value: json["value"],
  );

  Map<String, dynamic> toJson() => {
    "label": label,
    "value": value,
  };
}
