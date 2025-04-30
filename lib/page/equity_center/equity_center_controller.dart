import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/color_style_util.dart';

import '../../model/equity_center_model.dart';
import '../../services/equity_center_service.dart';

class EquityCenterController extends GetxController {
  final CarouselSliderController carouselController = CarouselSliderController();

  RxList<EquityCenterBannerModel> bannerList = <EquityCenterBannerModel>[].obs;
  RxList<EquityExpModel> expDataList = <EquityExpModel>[].obs;
  RxList<EquityLevelRecordModel> levelDataList = <EquityLevelRecordModel>[].obs;
  RxList<EquityLevelRecordModel> scoreDataList = <EquityLevelRecordModel>[].obs;

  // 背景图
  RxString bg = Assets.equityCenter.iconCenterNormalBg.path.obs;
  int selectIndex = 0;
  int userIndex = 0;
  var bannerModel = EquityCenterBannerModel().obs;
  var userLevelModel = EquityCenterBannerModel().obs;
  RxInt remainingPoints = 0.obs;
  int pointsToDay = 0;
  int levelPoints = 0;
  int integral = 0;
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
      integral = data['integral'] ?? 0;
      final expData = data['exp'] ?? [];
      final levelRecord = data['levelRecord'] ?? [];
      final scoreRecord = data['integralRecord'] ?? [];
      List<EquityExpModel> saveExpData = [];
      List<EquityLevelRecordModel> saveRecordData = [];
      List<EquityLevelRecordModel> saveScoreRecord = [];
      for (final map in expData) {
        saveExpData.add(EquityExpModel.fromJson(map));
      }
      for (final map in levelRecord) {
        saveRecordData.add(EquityLevelRecordModel.fromJson(map));
      }
      for (final map in scoreRecord) {
        saveScoreRecord.add(EquityLevelRecordModel.fromJson(map));
      }
      expDataList.value = saveExpData;
      levelDataList.value = saveRecordData;
      scoreDataList.value = saveScoreRecord;
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
        userIndex = i;
        break;
      }
    }
    for (int i = 0; i < data.length; i++) {
      final map = data[i];
      int minPoints = levelPoints;
      int maxPoints = map['maxPoints'] ?? 0;
      String name = map['name'] ?? "";
      if (map['index'] == 1) {
        saveData.add(EquityCenterBannerModel(
          title: name,
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
        saveData.add(EquityCenterBannerModel(
          title: name,
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
        int iIndex = (map['index'] ?? 1) - 1;
        if (iIndex < 0) {
          iIndex = 0;
        }
        saveData.add(EquityCenterBannerModel(
          title: name,
          index: iIndex,
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
    /// 临时加的调整
    for (int i = 0; i < saveData.length; i++) {
      if (i == 0 || i == 1) {
        saveData[i].bg = Assets.equityCenter.iconCenterNormalBg.path;
        saveData[i].rollBg = Assets.equityCenter.iconCenterRollBg.path;
        saveData[i].levelIcon = Assets.equityCenter.iconCenterLevelBg.path;
        saveData[i].buttonIcon = Assets.equityCenter.iconCenterNormalButton.path;
        saveData[i].titleColor = ColorStyle.c333333;
        saveData[i].levelColor = ColorStyle.c0F51BB;
        saveData[i].shadowColor = ColorStyle.cA4B2D5.withOpacity(0.5);
      } else if (i == 2 || i == 3 || i == 4) {
        saveData[i].bg = Assets.equityCenter.iconCenterHighBg.path;
        saveData[i].rollBg = Assets.equityCenter.iconCenterRollHighBg.path;
        saveData[i].levelIcon = Assets.equityCenter.iconCenterHighLevelBg.path;
        saveData[i].buttonIcon = Assets.equityCenter.iconCenterHighButton.path;
        saveData[i].titleColor = ColorStyle.c333333;
        saveData[i].levelColor = ColorStyle.c0F51BB;
        saveData[i].shadowColor = ColorStyle.cA3A4A5.withOpacity(0.5);
      } else {
        saveData[i].bg = Assets.equityCenter.iconCenterHighBg2.path;
        saveData[i].rollBg = Assets.equityCenter.iconCenterRollHighBg2.path;
        saveData[i].levelIcon = Assets.equityCenter.iconCenterHighLevelBg2.path;
        saveData[i].buttonIcon = Assets.equityCenter.iconCenterHigh2Button.path;
        saveData[i].titleColor = ColorStyle.c333333;
        saveData[i].levelColor = ColorStyle.c0F51BB;
        saveData[i].shadowColor = ColorStyle.cAE9E86.withOpacity(0.5);
      }
    }
    userLevelModel.value = saveData[selectIndex];
    bannerList.value = saveData;
    bannerModel.value = bannerList[selectIndex];
    bg.value = bannerList[selectIndex].bg ?? '';
  }

  // TODO: Public Method

  void onPageChanged(int index) {
    bg.value = bannerList[index].bg ?? '';
    selectIndex = index;
    bannerModel.value = bannerList[index];
  }

  String getTaskIcon(String code) {
    String icon = Assets.equityCenter.iconEquityLogin.path;
    switch (code) {
      case 'LOGIN':
        return Assets.equityCenter.iconEquityLogin.path;
      case 'THREAD_RELEASE':
        return Assets.equityCenter.iconEquitySend.path;
      case 'COMMENT':
        return Assets.equityCenter.iconEquityReplay.path;
      case 'LIKE':
        icon = Assets.equityCenter.iconEquityGood.path;
      case 'COLLECT':
        return Assets.equityCenter.iconEquityLike.path;
      case 'FOLLOWED':
        return Assets.equityCenter.iconEquityFocus.path;
      case 'BEING_FOLLOWED':
        return Assets.equityCenter.iconEquityGetFocus.path;
      case 'other':
        return Assets.equityCenter.iconEquityLogin.path;
    }
    return icon;
  }
}
