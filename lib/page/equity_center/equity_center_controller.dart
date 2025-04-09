import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/utils/color_style_util.dart';

import '../../model/equity_center_model.dart';

class EquityCenterController extends GetxController {
  final CarouselSliderController carouselController =
      CarouselSliderController();

  RxList<EquityCenterBannerModel> bannerList = <EquityCenterBannerModel>[
    EquityCenterBannerModel(
      title: '0',
      index: 0,
      bg: Assets.equityCenter.iconCenterNormalBg.path,
      rollBg: Assets.equityCenter.iconCenterRollBg.path,
      titleIcon: Assets.equityCenter.iconCenterNormalUser.path,
      levelIcon: Assets.equityCenter.iconCenterLevelBg.path,
      buttonIcon: Assets.equityCenter.iconCenterNormalButton.path,
      titleColor: ColorStyle.c0F51BB,
      shadowColor: ColorStyle.c2856E5,
    ),
    EquityCenterBannerModel(
      title: '1',
      index: 1,
      bg: Assets.equityCenter.iconCenterHighBg.path,
      rollBg: Assets.equityCenter.iconCenterRollHighBg.path,
      titleIcon: Assets.equityCenter.iconCenterHighUser.path,
      levelIcon: Assets.equityCenter.iconCenterHighLevelBg.path,
      buttonIcon: Assets.equityCenter.iconCenterHighButton.path,
      titleColor: ColorStyle.c29426A,
      shadowColor: ColorStyle.c6CABFF,
    ),
    EquityCenterBannerModel(
      title: '2',
      index: 2,
      bg: Assets.equityCenter.iconCenterHighBg2.path,
      rollBg: Assets.equityCenter.iconCenterRollHighBg2.path,
      titleIcon: Assets.equityCenter.iconCenterHigh2User.path,
      levelIcon: Assets.equityCenter.iconCenterHighLevelBg2.path,
      buttonIcon: Assets.equityCenter.iconCenterHigh2Button.path,
      titleColor: ColorStyle.c5D2900,
      shadowColor: ColorStyle.cF3A948,
    ),
  ].obs;

  // 背景图
  RxString bg = Assets.equityCenter.iconCenterNormalBg.path.obs;
  int selectIndex = 0;
  var bannerModel = EquityCenterBannerModel().obs;

  @override
  void onReady() {
    bannerModel.value = bannerList[0];
    super.onReady();
  }

  @override
  void onClose() {

    super.onClose();
  }

  // TODO: Public Method

  void onPageChanged(int index) {
    bg.value = bannerList[index].bg ?? '';
    selectIndex = index;
    bannerModel.value = bannerList[index];
  }
}
