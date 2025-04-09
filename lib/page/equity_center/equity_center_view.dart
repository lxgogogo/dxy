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
        Obx(() => Image.asset(
              controller.bg.value,
              width: 1.sw,
              fit: BoxFit.fitWidth,
            )),
        Scaffold(
            backgroundColor: Colors.transparent,
            appBar: CommonAppBar.arrowBack(context, title: '权益中心'),
            body: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBannerWidget(),
                    _buildCategoryWidget(),
                    Expanded(
                        child: Container(
                            margin: EdgeInsets.only(top: 10.w),
                            decoration: BoxDecoration(
                                color: ColorStyle.cF5F5F5,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10.w),
                                    topRight: Radius.circular(10.w))),
                            child: SafeArea(
                                child: SingleChildScrollView(
                                    child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDayTaskWidget(),
                                SizedBox(height: 10.w),
                                _buildRunWidget()
                              ],
                            )))))
                  ],
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
          onPageChanged: (index, reason) {
            controller.onPageChanged(index);
          }),
      items: controller.bannerList.map((item) {
        return GestureDetector(
            onTap: () async {},
            child: Stack(
              children: [
                SizedBox(height: 178.w),
                Container(
                  width: 1.sw * 0.9,
                  height: 148.w,
                  padding: EdgeInsets.only(left: 16.w, top: 16.w, right: 16.w),
                  margin: EdgeInsets.only(left: 6.w, right: 6.w, top: 15.w),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(item.rollBg ?? ''),
                          fit: BoxFit.fill),
                      boxShadow: [
                        BoxShadow(
                            color: (item.shadowColor ?? ColorStyle.c6CABFF)
                                .withOpacity(0.5),
                            offset: const Offset(0, 4),
                            blurRadius: 12,
                            spreadRadius: 0),
                      ]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        item.titleIcon ?? '',
                        width: 96.w,
                        fit: BoxFit.fitWidth,
                      ),
                      SizedBox(height: 15.w),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '经验值 60',
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        color: item.titleColor
                                    ),
                                  ),
                                  Text(
                                    '/500',
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        color: (item.titleColor ?? ColorStyle.c333333).withOpacity(0.5)
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5.w),
                              Stack(
                                children: [
                                  Container(
                                    width: 96.w,
                                    height: 2.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(1.w)),
                                      color: ColorStyle.c29426A.withOpacity(0.2),
                                    ),
                                  ),
                                  Container(
                                    width: 20.w,
                                    height: 2.w,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(1.w)),
                                        color: item.titleColor
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(width: 10.w),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: 60.w,
                              height: 24.w,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(item.buttonIcon ?? ''),
                                  fit: BoxFit.fill
                                )
                              ),
                              child: Text(
                                controller.selectIndex == 0 ? '去升级' : '去完成',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: ColorStyle.white
                                )
                              ),
                            )
                          )
                        ],
                      ),
                      const Expanded(child: SizedBox()),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          height: 36.w,
                          padding: EdgeInsets.only(left: 12.w, right: 12.w),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(8.w)),
                              color: ColorStyle.white.withOpacity(0.3)
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '今日做任务还可得120成长值',
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    color: item.titleColor
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '去完成',
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        color: item.titleColor
                                    ),
                                  ),
                                  Image.asset(
                                    Assets.images.arrowRight.path,
                                    width: 12.w,
                                    height: 12.w,
                                    fit: BoxFit.cover,
                                    color: item.titleColor,
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10.w)
                    ],
                  ),
                ),
                Positioned(
                  right: 20.w,
                  child: Image.asset(
                    item.levelIcon ?? '',
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
    var iconData = [
      Assets.equityCenter.iconCenterBook.path,
      Assets.equityCenter.iconCenterVideo.path,
      Assets.equityCenter.iconCenterHighVideo.path,
      Assets.equityCenter.iconCenterCollect.path,
      Assets.equityCenter.iconCenterCollectGroup.path,
    ];
    var contentData = ['2本/天', '102分钟', '2部/天', '50', ''];
    var titleData = ['书籍下载', '基本视频', '高级视频', '收藏', '收藏分类'];
    if (controller.selectIndex == 1) {
      iconData = [
        Assets.equityCenter.iconCenterHighBook.path,
        Assets.equityCenter.iconCenterHighUpVideo.path,
        Assets.equityCenter.iconCenterHighTopVideo.path,
        Assets.equityCenter.iconCenterHighCollect.path,
        Assets.equityCenter.iconCenterHighCollectGroup.path,
      ];
      contentData = ['2本/天', '102分钟', '2部/天', '50', ''];
    } else if (controller.selectIndex == 2) {
      iconData = [
        Assets.equityCenter.iconCenterHigh2Book.path,
        Assets.equityCenter.iconCenterHigh2UpVideo.path,
        Assets.equityCenter.iconCenterHigh2TopVideo.path,
        Assets.equityCenter.iconCenterHigh2Collect.path,
        Assets.equityCenter.iconCenterHigh2CollectGroup.path,
      ];
      contentData = ['2本/天', '102分钟', '2部/天', '50', ''];
    }
    List<Map<String, dynamic>> data = [];
    for (int i = 0; i < iconData.length; i++) {
      data.add({
        'icon': iconData[i],
        'title': titleData[i],
        'content': contentData[i]
      });
    }
    final model = controller.bannerModel.value;
    return Container(
        padding: EdgeInsets.only(left: 5.w, right: 5.w),
        child: Wrap(
          children: [
            ...data.map((e) {
              return Container(
                width: (1.sw - 10.w) / 5,
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
                      style:
                          TextStyle(fontSize: 12.sp, color: model.titleColor),
                    ),
                    Text(
                      e['content'],
                      style:
                          TextStyle(fontSize: 10.sp, color: model.titleColor),
                    ),
                  ],
                ),
              );
            })
          ],
        ));
  }

  Widget _buildDayTaskWidget() {
    return Container(
      margin: EdgeInsets.only(left: 10.w, right: 10.w),
      padding: EdgeInsets.all(24.w).copyWith(bottom: 16.w),
      decoration: BoxDecoration(
          color: ColorStyle.white,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10.w),
              bottomRight: Radius.circular(10.w))),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '每日任务',
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: ColorStyle.c333333),
              ),
              SizedBox(width: 10.w),
              Text(
                '多领多赚，单日最高 120',
                style: TextStyle(fontSize: 12.sp, color: ColorStyle.c333333),
              )
            ],
          ),
          SizedBox(height: 10.w),
          Wrap(
            children: [
              _buildDayTaskItemWidget(),
              _buildDayTaskItemWidget(),
              _buildDayTaskItemWidget(),
              _buildDayTaskItemWidget(),
              _buildDayTaskItemWidget()
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDayTaskItemWidget() {
    return SizedBox(
        height: 58.w,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                    width: 38.w,
                    height: 38.w,
                    clipBehavior: Clip.antiAlias,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(
                                Assets.equityCenter.iconCenterYuanBg.path),
                            fit: BoxFit.fill)),
                    child: Text(
                      '+5',
                      style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: ColorStyle.c557BF6),
                    )),
                SizedBox(width: 15.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '登录',
                      style:
                          TextStyle(fontSize: 12.sp, color: ColorStyle.c333333),
                    ),
                    SizedBox(height: 5.w),
                    Text(
                      '每日登录即可领取10经验值',
                      style:
                          TextStyle(fontSize: 10.sp, color: ColorStyle.c333333),
                    )
                  ],
                ),
              ],
            ),
            Container(
              width: 66.w,
              height: 30.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8.w)),
                  color: ColorStyle.c557BF6.withOpacity(0.1)),
              child: Text(
                '已完成',
                style: TextStyle(
                    fontSize: 12.sp,
                    color: ColorStyle.c557BF6.withOpacity(0.7)),
              ),
            )
          ],
        ));
  }

  Widget _buildRunWidget() {
    return Container(
      margin: EdgeInsets.only(left: 10.w, right: 10.w),
      padding: EdgeInsets.all(24.w).copyWith(bottom: 16.w),
      decoration: BoxDecoration(
          color: ColorStyle.white,
          borderRadius: BorderRadius.all(Radius.circular(10.w))),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '成长值记录',
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: ColorStyle.c333333),
              ),
              SizedBox(width: 10.w),
              Text(
                '显示最近6个月的经验值记录',
                style: TextStyle(fontSize: 12.sp, color: ColorStyle.c333333),
              )
            ],
          ),
          SizedBox(height: 10.w),
          Wrap(
            children: [
              _buildRunItemWidget(),
              _buildRunItemWidget(),
              _buildRunItemWidget(),
              _buildRunItemWidget(),
              _buildRunItemWidget()
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRunItemWidget() {
    return SizedBox(
        height: 48.w,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '2025年3月',
              style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: ColorStyle.c333333),
            ),
            Text(
              '+120',
              style: TextStyle(fontSize: 14.sp, color: ColorStyle.c333333),
            )
          ],
        ));
  }
}
