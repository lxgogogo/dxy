import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../gen/assets.gen.dart';
import '../../utils/color_style_util.dart';
import '../../widget/common_app_bar.dart';
import 'equity_center_controller.dart';

class EquityCenterPage extends StatefulWidget {
  const EquityCenterPage({Key? key}) : super(key: key);

  @override
  State<EquityCenterPage> createState() => _EquityCenterPageState();
}

class _EquityCenterPageState extends State<EquityCenterPage> {
  final EquityCenterController controller = Get.put(EquityCenterController());

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
            ColorStyle.c557BF6,
            ColorStyle.cCFF1FF,
          ], begin: Alignment.centerRight, end: Alignment.centerLeft)),
          child: Container(
            margin: EdgeInsets.only(top: 380.w),
            decoration: BoxDecoration(
                color: ColorStyle.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.w),
                    topRight: Radius.circular(10.w))),
          ),
        ),
        Scaffold(
            backgroundColor: Colors.transparent,
            appBar: CommonAppBar.arrowBack(context,
                title: '权益中心',
                backgroundColor: Colors.red,
                titleColor: ColorStyle.white,
                arrowColor: ColorStyle.white),
            body: Obx(() => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBannerWidget(),
                  _buildCategoryWidget(),
                  _buildDayTaskWidget()
                ],
              )
            )))
      ],
    );
  }

  @override
  void dispose() {
    Get.delete<EquityCenterController>();
    super.dispose();
  }

  // TODO: Build widget

  Widget _buildBannerWidget() {
    return CarouselSlider(
      carouselController: controller.carouselController,
      options: CarouselOptions(
          viewportFraction: 0.9,
          height: 178.w,
          clipBehavior: Clip.antiAlias,
          onPageChanged: (index, reason) {}),
      items: controller.bannerList.map((item) {
        return GestureDetector(
            onTap: () async {},
            child: Stack(
              children: [
                Container(
                  width: 1.sw*0.9,
                  height: 178.w,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(
                              Assets.equityCenter.iconCenterRollBg.path),
                          fit: BoxFit.fitWidth)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('212')
                    ],
                  ),
                ),
                Positioned(
                  right: 30.w,
                  child: Image.asset(
                    Assets.equityCenter.iconCenterLevelBg.path,
                    width: 116.w,
                    height: 102.w,
                    fit: BoxFit.cover,
                  ),
                )
              ],
            ));
      }).toList(),
    );
  }

  Widget _buildCategoryWidget() {
    List<Map<String, dynamic>> data = [
      {
        'icon': Assets.equityCenter.iconCenterBook.path,
        'title': '书籍下载',
        'content': '2本/天'
      },
      {
        'icon': Assets.equityCenter.iconCenterBook.path,
        'title': '书籍下载',
        'content': '2本/天'
      },
      {
        'icon': Assets.equityCenter.iconCenterBook.path,
        'title': '书籍下载',
        'content': '2本/天'
      },
      {
        'icon': Assets.equityCenter.iconCenterBook.path,
        'title': '书籍下载',
        'content': '2本/天'
      },
      {
        'icon': Assets.equityCenter.iconCenterBook.path,
        'title': '书籍下载',
        'content': '2本/天'
      },
    ];
    return Container(
        padding: EdgeInsets.only(left: 20.w, right: 20.w),
        child: Wrap(
          children: [
            ...data.map((e) {
              return Container(
                width: (1.sw - 40.w)/5,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      e['icon'],
                      width: 42.w,
                      height: 42.w,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 10.w),
                    Text(
                      e['title'],
                      style: TextStyle(
                          fontSize: 12.sp,
                          color: ColorStyle.white
                      ),
                    ),
                    Text(
                      e['content'],
                      style: TextStyle(
                          fontSize: 10.sp,
                          color: ColorStyle.white
                      ),
                    ),
                  ],
                ),
              );
            })
          ],
        )
    );
  }

  Widget _buildDayTaskWidget() {
    return Container();
  }
}
