import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';

import '../../model/equity_center_model.dart';

class EquityCenterController extends GetxController {

  final CarouselSliderController carouselController = CarouselSliderController();

  RxList<EquityCenterBannerModel> bannerList = <EquityCenterBannerModel>[
    EquityCenterBannerModel(title: '1'),
    EquityCenterBannerModel(title: '1'),
    EquityCenterBannerModel(title: '1'),
  ].obs;

  @override
  void onReady() {
    super.onReady();
    Future.delayed(const Duration(milliseconds: 1000), () {
      bannerList.value = [
        EquityCenterBannerModel(title: '1'),
        EquityCenterBannerModel(title: '1'),
        EquityCenterBannerModel(title: '1'),
      ];
    });
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }
}
