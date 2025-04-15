import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/utils/color_style_util.dart';

import '../../model/equity_center_model.dart';
import '../../services/equity_center_service.dart';

class EquityCenterController extends GetxController {
  final CarouselSliderController carouselController =
      CarouselSliderController();

  RxList<EquityCenterBannerModel> bannerList = <EquityCenterBannerModel>[].obs;

  // 背景图
  RxString bg = Assets.equityCenter.iconCenterNormalBg.path.obs;
  int selectIndex = 0;
  var bannerModel = EquityCenterBannerModel().obs;

  @override
  void onReady() {
    _requestData();
    super.onReady();
  }

  // TODO: Private Method

  void _requestData() async {
    final res = await EquityCenterService.userEquity();
    if (res.isSuccess) {
      _getData(res.data ?? {});
    }
  }

  void _getData(res) {
    final data = res['userLevel'] ?? [];
    selectIndex = (res['userLevelId'] ?? 1) - 1;
    List<EquityCenterBannerModel> saveData = [];
    for (int i = 0; i < data.length; i++) {
      final map = data[i];
      if (map['index'] == 1) {
        saveData.add(EquityCenterBannerModel(
          title: '一般用户',
          index: 0,
          bg: Assets.equityCenter.iconCenterNormalBg.path,
          rollBg: Assets.equityCenter.iconCenterRollBg.path,
          levelIcon: Assets.equityCenter.iconCenterLevelBg.path,
          buttonIcon: Assets.equityCenter.iconCenterNormalButton.path,
          titleColor: ColorStyle.c333333,
          levelColor: ColorStyle.c0F51BB,
          shadowColor: ColorStyle.cA4B2D5.withOpacity(0.5),
          maxPoints: data['maxPoints'],
          minPoints: data['minPoints'],
          bookDownload: data['bookDownload'],
          videoWatch: data['videoWatch'],
          featured: data['featured'],
          favorite: data['favorite'],
          favoriteCategory: data['favoriteCategory'],
        ));
      } else if (map['index'] == 2) {
        saveData.add(EquityCenterBannerModel(
          title: '高级用户',
          index: 1,
          bg: Assets.equityCenter.iconCenterHighBg.path,
          rollBg: Assets.equityCenter.iconCenterRollHighBg.path,
          levelIcon: Assets.equityCenter.iconCenterHighLevelBg.path,
          buttonIcon: Assets.equityCenter.iconCenterHighButton.path,
          titleColor: ColorStyle.c333333,
          levelColor: ColorStyle.c0F51BB,
          shadowColor: ColorStyle.cA3A4A5.withOpacity(0.5),
          maxPoints: data['maxPoints'],
          minPoints: data['minPoints'],
          bookDownload: data['bookDownload'],
          videoWatch: data['videoWatch'],
          featured: data['featured'],
          favorite: data['favorite'],
          favoriteCategory: data['favoriteCategory'],
        ));
      } else {
        saveData.add(EquityCenterBannerModel(
          title: '皇家用户',
          index: 2,
          bg: Assets.equityCenter.iconCenterHighBg2.path,
          rollBg: Assets.equityCenter.iconCenterRollHighBg2.path,
          levelIcon: Assets.equityCenter.iconCenterHighLevelBg2.path,
          buttonIcon: Assets.equityCenter.iconCenterHigh2Button.path,
          titleColor: ColorStyle.c333333,
          levelColor: ColorStyle.c0F51BB,
          shadowColor: ColorStyle.cAE9E86.withOpacity(0.5),
          maxPoints: data['maxPoints'],
          minPoints: data['minPoints'],
          bookDownload: data['bookDownload'],
          videoWatch: data['videoWatch'],
          featured: data['featured'],
          favorite: data['favorite'],
          favoriteCategory: data['favoriteCategory'],
        ));
      }
    }
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
