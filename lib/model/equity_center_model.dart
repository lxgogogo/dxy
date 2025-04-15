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

  double? maxPoints;
  double? minPoints;
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
