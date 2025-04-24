import 'package:flutter/material.dart';

class EquityCenterModel {}

class EquityCenterBannerModel {
  String? title;
  int? index;
  String? bg;
  String? rollBg;
  String? titleIcon;
  String? levelIcon;
  String? buttonIcon;
  Color? titleColor;
  Color? levelColor;
  Color? shadowColor;

  int? maxPoints;
  int? minPoints;
  int? bookDownload;
  int? videoWatch;
  int? featured;
  int? favorite;
  int? favoriteCategory;

  EquityCenterBannerModel(
      {this.title,
      this.index,
      this.bg,
      this.rollBg,
      this.titleIcon,
      this.levelIcon,
      this.buttonIcon,
      this.titleColor,
      this.levelColor,
      this.shadowColor,
      this.maxPoints,
      this.minPoints,
      this.bookDownload,
      this.videoWatch,
      this.featured,
      this.favorite,
      this.favoriteCategory});
}

class EquityExpModel {

  String? code;
  String? name;
  int? points;
  String? description;
  int? limitNum;
  int? completedNum;
  bool? completed;

  EquityExpModel({
    this.name,
    this.points,
    this.description,
    this.limitNum,
    this.completedNum,
    this.completed,
    this.code});

  EquityExpModel.fromJson(Map<String, dynamic> json) {
    if (json["points"] is int) {
      points = json["points"];
    }
    if (json["name"] is String) {
      name = json["name"];
    }
    if (json["code"] is String) {
      code = json["code"];
    }
    if (json["description"] is String) {
      description = json["description"];
    }
    if (json["limitNum"] is int) {
      limitNum = json["limitNum"];
    }
    if (json["completedNum"] is int) {
      completedNum = json["completedNum"];
    }
    if (json["completed"] is bool) {
      completed = json["completed"];
    }

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["points"] = points;
    _data["name"] = name;
    _data["description"] = description;
    _data["completedNum"] = completedNum;
    _data["limitNum"] = limitNum;
    _data["completed"] = completed;
    _data["code"] = code;
    return _data;
  }
}

class EquityLevelRecordModel {

  String? month;
  int? pointsSum;

  EquityLevelRecordModel({
    this.month,
    this.pointsSum});

  EquityLevelRecordModel.fromJson(Map<String, dynamic> json) {
    if (json["pointsSum"] is int) {
      pointsSum = json["pointsSum"];
    }
    if (json["month"] is String) {
      month = json["month"];
    }

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["month"] = month;
    _data["pointsSum"] = pointsSum;
    return _data;
  }
}
