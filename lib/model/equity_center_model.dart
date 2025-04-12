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
      this.shadowColor});
}
