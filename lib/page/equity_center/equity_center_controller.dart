import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/utils/color_style_util.dart';

import '../../model/equity_center_model.dart';
import '../../services/equity_center_service.dart';

class EquityCenterController extends GetxController {
  final CarouselSliderController carouselController =
      CarouselSliderController();

  RxList<EquityCenterBannerModel> bannerList = <EquityCenterBannerModel>[].obs;
  RxList<EquityExpModel> expDataList = <EquityExpModel>[].obs;
  RxList<EquityLevelRecordModel> levelDataList = <EquityLevelRecordModel>[].obs;

  // 背景图
  RxString bg = Assets.equityCenter.iconCenterNormalBg.path.obs;
  int selectIndex = 0;
  var bannerModel = EquityCenterBannerModel().obs;
  var userLevelModel = EquityCenterBannerModel().obs;
  RxInt remainingPoints = 0.obs;
  int pointsToDay = 0;
  int levelPoints = 0;
  RxBool isLoading = true.obs;

  @override
  void onReady() {
    _requestData();
    super.onReady();
  }

  // TODO: Private Method

  void _requestData() async {
    final res = await EquityCenterService.userEquity();
    if (res.isSuccess) {
      final data = res.data ?? {};
      remainingPoints.value = data['remainingPoints'] ?? 0;
      pointsToDay = data['pointsToDay'] ?? 0;
      levelPoints = data['levelPoints'] ?? 0;
      final expData = data['exp'] ?? [];
      final levelRecord = data['levelRecord'] ?? [];
      List<EquityExpModel> saveExpData = [];
      List<EquityLevelRecordModel> saveRecordData = [];
      for (final map in expData) {
        saveExpData.add(EquityExpModel.fromJson(map));
      }
      for (final map in levelRecord) {
        saveRecordData.add(EquityLevelRecordModel.fromJson(map));
      }
      expDataList.value = saveExpData;
      levelDataList.value = saveRecordData;
      // banner
      _getData(data);
    }
    isLoading.value = false;
  }

  void _getData(res) {
    final data = res['userLevelList'] ?? [];
    int userLevelId = (res['userLevelId'] ?? 0);
    List<EquityCenterBannerModel> saveData = [];
    for (int i = 0; i < data.length; i++) {
      final map = data[i];
      if (userLevelId == (map['id'] ?? 0)) {
        selectIndex = i;
      }
    }
    for (int i = 0; i < data.length; i++) {
      final map = data[i];
      int minPoints = map['minPoints'] ?? 0;
      int maxPoints = map['maxPoints'] ?? 0;
      if (userLevelId == (map['id'] ?? 0)) {
        minPoints = levelPoints;
      }
      if (map['index'] == 1) {
        if (selectIndex > 0) {
          minPoints = maxPoints;
        }
        saveData.add(EquityCenterBannerModel(
          title: map['name'] ??"",
          index: 0,
          bg: Assets.equityCenter.iconCenterNormalBg.path,
          rollBg: Assets.equityCenter.iconCenterRollBg.path,
          levelIcon: Assets.equityCenter.iconCenterLevelBg.path,
          buttonIcon: Assets.equityCenter.iconCenterNormalButton.path,
          titleColor: ColorStyle.c333333,
          levelColor: ColorStyle.c0F51BB,
          shadowColor: ColorStyle.cA4B2D5.withOpacity(0.5),
          maxPoints: maxPoints,
          minPoints: minPoints,
          bookDownload: map['bookDownload'],
          videoWatch: map['videoWatch'],
          featured: map['featured'],
          favorite: map['favorite'],
          favoriteCategory: map['favoriteCategory'],
        ));
      } else if (map['index'] == 2) {
        if (selectIndex > 1) {
          minPoints = maxPoints;
        }
        saveData.add(EquityCenterBannerModel(
          title: map['name'] ??"",
          index: 1,
          bg: Assets.equityCenter.iconCenterHighBg.path,
          rollBg: Assets.equityCenter.iconCenterRollHighBg.path,
          levelIcon: Assets.equityCenter.iconCenterHighLevelBg.path,
          buttonIcon: Assets.equityCenter.iconCenterHighButton.path,
          titleColor: ColorStyle.c333333,
          levelColor: ColorStyle.c0F51BB,
          shadowColor: ColorStyle.cA3A4A5.withOpacity(0.5),
          maxPoints: maxPoints,
          minPoints: minPoints,
          bookDownload: map['bookDownload'],
          videoWatch: map['videoWatch'],
          featured: map['featured'],
          favorite: map['favorite'],
          favoriteCategory: map['favoriteCategory'],
        ));
      } else {
        // 非最后一个
        if (selectIndex > 2 && i != data.length - 1) {
          minPoints = maxPoints;
        }
        saveData.add(EquityCenterBannerModel(
          title: map['name'] ??"",
          index: 2,
          bg: Assets.equityCenter.iconCenterHighBg2.path,
          rollBg: Assets.equityCenter.iconCenterRollHighBg2.path,
          levelIcon: Assets.equityCenter.iconCenterHighLevelBg2.path,
          buttonIcon: Assets.equityCenter.iconCenterHigh2Button.path,
          titleColor: ColorStyle.c333333,
          levelColor: ColorStyle.c0F51BB,
          shadowColor: ColorStyle.cAE9E86.withOpacity(0.5),
          maxPoints: maxPoints,
          minPoints: minPoints,
          bookDownload: map['bookDownload'],
          videoWatch: map['videoWatch'],
          featured: map['featured'],
          favorite: map['favorite'],
          favoriteCategory: map['favoriteCategory'],
        ));
      }
    }
    if (selectIndex > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        carouselController.jumpToPage(selectIndex);
      });
    }
    userLevelModel.value = saveData[selectIndex];
    bannerList.value = saveData;
    bannerModel.value = bannerList[selectIndex];
  }

  // TODO: Public Method

  void onPageChanged(int index) {
    bg.value = bannerList[index].bg ?? '';
    selectIndex = index;
    bannerModel.value = bannerList[index];
  }
}
