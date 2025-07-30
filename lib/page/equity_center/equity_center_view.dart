import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/app_theme.dart';

import '../../gen/assets.gen.dart';
import '../../model/equity_center_model.dart';
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
    return Obx(() => Stack(
      children: [
        if (controller.isLoading.value)
          const SizedBox()
        else
          Image.asset(
            controller.bg.value,
            width: 1.sw,
            height: 1.sh,
            fit: BoxFit.fill,
          ),
        Positioned(
          bottom: 0,
          child: Container(
            width: 1.sw,
            height: 260.w,
            color: ColorStyle.cF5F5F5,
          ),
        ),
        Scaffold(
            backgroundColor: controller.isLoading.value
                ? Colors.white
                : Colors.transparent,
            appBar: CommonAppBar.arrowBack(
                context, title: '权益中心', onBack: controller.onBack),
            body: controller.isLoading.value
                ? const Center(
              child: CupertinoActivityIndicator(color: Colors.grey),
            )
                : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBannerWidget(),
                  _buildCategoryWidget(),
                  Container(
                      margin: EdgeInsets.only(top: 15.w),
                      decoration: BoxDecoration(
                          color: ColorStyle.cF5F5F5,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10.w),
                              topRight: Radius.circular(10.w))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDayTaskWidget(),
                          SizedBox(height: 10.w),
                          _buildRunWidget(),
                          SizedBox(height: 10.w),
                          _buildScoreWidget()
                        ],
                      )),
                  SafeArea(child: SizedBox())
                ],
              ),
            ))
      ],
    ));
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
          height: 158.w,
          initialPage: controller.selectIndex,
          clipBehavior: Clip.antiAlias,
          enableInfiniteScroll: false,
          onPageChanged: (index, reason) {
            controller.onPageChanged(index);
          }),
      items: controller.bannerList.map((item) {
        int maxPoint = item.maxPoints ?? 0;
        int minPoint = item.minPoints ?? 0;
        double allWidth = 1.sw * 0.9 - 32.w;
        double progressWidth = 0;
        int nowPoint = maxPoint - minPoint;
        if (maxPoint <= 0) {
          if (controller.userIndex ==
              controller.bannerList.length - 1) {
            progressWidth = allWidth;
          } else {
            progressWidth = 0;
          }
        } else {
          if (minPoint >= maxPoint) {
            progressWidth = allWidth;
          } else {
            progressWidth = minPoint / maxPoint * allWidth;
          }
        }
        return Stack(
          children: [
            SizedBox(height: 158.w),
            Container(
              width: 1.sw * 0.9,
              height: 158.w,
              padding: EdgeInsets.only(left: 16.w, top: 8.w, right: 16.w),
              margin: EdgeInsets.only(left: 6.w, right: 6.w, top: 15.w, bottom: 20.w),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(item.rollBg ?? ''), fit: BoxFit.fill),
                  boxShadow: [
                    BoxShadow(
                        color: (item.shadowColor ?? ColorStyle.c6CABFF)
                            .withOpacity(0.5),
                        offset: const Offset(0, 4),
                        blurRadius: 6,
                        spreadRadius: 0),
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    UserStore.of.user?.nickname ?? '',
                    style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: item.titleColor),
                  ),
                  SizedBox(height: 10.w),
                  Container(
                    height: 22.w,
                    constraints: BoxConstraints(maxWidth: 84.w),
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    alignment: Alignment.center,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(12.w)),
                        image: DecorationImage(
                            image: AssetImage(item.buttonIcon ?? ''),
                            fit: BoxFit.cover)),
                    child: AutoSizeText(item.title ?? '',
                        minFontSize: 8,
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: ColorStyle.white)),
                  ),
                  const Expanded(child: SizedBox()),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                '经验值',
                                style: TextStyle(
                                    fontSize: 12.sp, color: ColorStyle.c333333),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 1.5.w),
                                child: Text(
                                  ' ${item.minPoints ?? 0}',
                                  style: TextStyle(
                                      fontSize: 12.sp,
                                      color: item.titleColor),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 1.5.w),
                                child: Text(
                                  maxPoint > 0
                                      ? '/${item.maxPoints ?? 0}'
                                      : '/-',
                                  style: TextStyle(
                                      fontSize: 12.sp,
                                      color: (item.titleColor ??
                                          ColorStyle.c333333)
                                          .withOpacity(0.5)),
                                ),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                '积分 ',
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    color: (item.titleColor ??
                                        ColorStyle.c333333)),
                              ),
                              Text(
                                '${controller.integral}',
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    color: item.titleColor),
                              ),
                            ],
                          ),
                          if (nowPoint > 0)
                            Text(
                              '还差 $nowPoint经验值升级',
                              style: TextStyle(
                                  fontSize: 10.sp,
                                  color: (item.titleColor ?? ColorStyle.c333333)
                                      .withOpacity(0.7)),
                            )
                        ],
                      ),
                      SizedBox(height: 6.w),
                      Stack(
                        children: [
                          Container(
                            width: allWidth,
                            height: 2.w,
                            decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.all(Radius.circular(1.w)),
                              color: ColorStyle.c29426A.withOpacity(0.2),
                            ),
                          ),
                          Container(
                            width: progressWidth,
                            height: 2.w,
                            decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.all(Radius.circular(1.w)),
                                color: ColorStyle.c557BF6),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 12.w)
                ],
              ),
            ),
            Positioned(
              right: 5.w,
              child: Image.asset(
                item.levelIcon ?? '',
                width: 106.w,
                height: 92.w,
                fit: BoxFit.cover,
              ),
            )
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCategoryWidget() {
    if (controller.bannerList.isEmpty) {
      return SizedBox(height: 70.w);
    }
    final model = controller.userLevelModel.value;
    var iconData = [
      Assets.equityCenter.iconCenterBook.path,
      Assets.equityCenter.iconCenterVideo.path,
      Assets.equityCenter.iconCenterHighVideo.path,
      Assets.equityCenter.iconCenterCollect.path,
      Assets.equityCenter.iconCenterCollectGroup.path,
    ];
    if (controller.selectIndex >= 2 && controller.selectIndex <= 4) {
      iconData = [
        Assets.equityCenter.iconCenterBook2.path,
        Assets.equityCenter.iconCenterVideo2.path,
        Assets.equityCenter.iconCenterHighVideo2.path,
        Assets.equityCenter.iconCenterCollect2.path,
        Assets.equityCenter.iconCenterCollectGroup2.path,
      ];
    } else if (controller.selectIndex > 4) {
      iconData = [
        Assets.equityCenter.iconCenterBook3.path,
        Assets.equityCenter.iconCenterVideo3.path,
        Assets.equityCenter.iconCenterHighVideo3.path,
        Assets.equityCenter.iconCenterCollect3.path,
        Assets.equityCenter.iconCenterCollectGroup3.path,
      ];
    }
    const limitTitle = '无限制';
    var contentData = [
      (model.bookDownload ?? 0) == -1
          ? limitTitle
          : '${model.bookDownload ?? 0}本/天',
      (model.videoWatch ?? 0) == -1 ? limitTitle : '${model.videoWatch ?? 0}分钟',
      (model.featured ?? 0) == -1 ? limitTitle : '${model.featured ?? 0}部/天',
      (model.favorite ?? 0) == -1 ? limitTitle : '${model.favorite ?? 0}',
      (model.favoriteCategory ?? 0) == -1
          ? limitTitle
          : '${model.favoriteCategory ?? 0}'
    ];
    var titleData = ['书籍下载', '基本视频', '高级视频', '收藏', '收藏分类'];
    List<Map<String, dynamic>> data = [];
    for (int i = 0; i < iconData.length; i++) {
      bool suo = true;
      if (i == 0 && (model.bookDownload ?? 0) > 0 ||
          (model.bookDownload ?? 0) == -1) {
        suo = false;
      } else if (i == 1 && (model.videoWatch ?? 0) > 0 ||
          (model.videoWatch ?? 0) == -1) {
        suo = false;
      } else if (i == 2 && (model.featured ?? 0) > 0 ||
          (model.featured ?? 0) == -1) {
        suo = false;
      } else if (i == 3 && (model.favorite ?? 0) > 0 ||
          (model.favorite ?? 0) == -1) {
        suo = false;
      } else if (i == 4 && (model.favoriteCategory ?? 0) > 0 ||
          (model.favoriteCategory ?? 0) == -1) {
        suo = false;
      }
      data.add({
        'icon': iconData[i],
        'title': titleData[i],
        'content': contentData[i],
        'suo': suo
      });
    }
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
                    Stack(
                      children: [
                        Image.asset(
                          e['icon'],
                          width: 42.w,
                          height: 42.w,
                          fit: BoxFit.contain,
                        ),
                        if (e['suo'])
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Image.asset(
                              Assets.equityCenter.iconCenterSuo.path,
                              width: 22.w,
                              height: 22.w,
                              fit: BoxFit.cover,
                            ),
                          )
                      ],
                    ),
                    SizedBox(height: 10.w),
                    Text(
                      e['title'],
                      style: TextStyle(
                          fontSize: 12.sp,
                          color: model.titleColor,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 5.w),
                    Text(
                      e['content'],
                      style: TextStyle(
                          fontSize: 10.sp,
                          color: model.titleColor!.withOpacity(0.7)),
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
      padding: EdgeInsets.all(16.w).copyWith(bottom: 12.w),
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
              )
            ],
          ),
          SizedBox(height: 5.w),
          Wrap(
            children: [
              ...controller.expDataList.map((e) {
                return _buildDayTaskItemWidget(e);
              })
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDayTaskItemWidget(EquityExpModel model) {
    String title =
        '${model.name ?? ''}（${model.completedNum}/${model.limitNum}）';
    if ((model.name ?? '').contains('登录')) {
      title = model.name ?? '';
    }
    return SizedBox(
        height: 58.w,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  controller.getTaskIcon(model.code ?? ''),
                  width: 38.w,
                  height: 38.w,
                  fit: BoxFit.cover,
                ),
                SizedBox(width: 15.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style:
                      TextStyle(fontSize: 12.sp, color: ColorStyle.c333333),
                    ),
                    SizedBox(height: 5.w),
                    SizedBox(
                      width: 1.sw - 184.w,
                      child: Text(
                        model.description ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 10.sp,
                            color: ColorStyle.c333333.withOpacity(0.7)),
                      ),
                    )
                  ],
                ),
              ],
            ),
            if (model.completed == false)
              Container(
                width: 72.w,
                height: 28.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8.w)),
                    color: ColorStyle.c557BF6.withOpacity(0.1)),
                child: Text(
                  '进行中',
                  style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: !(model.completed ?? false) ? FontWeight.w600 : FontWeight.w400,
                      color: (model.completed ?? false)
                          ? ColorStyle.c557BF6.withOpacity(0.7)
                          : ColorStyle.c557BF6),
                ),
              )
            else
              Container(
                width: 72.w,
                height: 28.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8.w)),
                    color: ColorStyle.c557BF6.withOpacity(0.1)),
                child: Text(
                  '已完成',
                  style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: ColorStyle.c557BF6.withOpacity(0.7)),
                ),
              )
          ],
        ));
  }

  Widget _buildRunWidget() {
    return Container(
      margin: EdgeInsets.only(left: 10.w, right: 10.w),
      padding: EdgeInsets.all(16.w).copyWith(bottom: 12.w),
      decoration: BoxDecoration(
          color: ColorStyle.white,
          borderRadius: BorderRadius.all(Radius.circular(10.w))),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '经验值记录',
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: ColorStyle.c333333),
              ),
              SizedBox(width: 10.w),
              Text(
                '显示最近6个月的经验值记录',
                style: TextStyle(
                    fontSize: 12.sp,
                    color: ColorStyle.c333333.withOpacity(0.7)),
              )
            ],
          ),
          SizedBox(height: 5.w),
          Wrap(
            children: [
              ...controller.levelDataList.map((e) {
                return _buildRunItemWidget(e);
              })
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRunItemWidget(EquityLevelRecordModel model) {
    return SizedBox(
        height: 40.w,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              model.month ?? '',
              style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: ColorStyle.c333333),
            ),
            Text(
              '+${model.pointsSum ?? 0}',
              style: TextStyle(fontSize: 14.sp, color: ColorStyle.c333333),
            )
          ],
        ));
  }

  Widget _buildScoreWidget() {
    return Container(
      margin: EdgeInsets.only(left: 10.w, right: 10.w),
      padding: EdgeInsets.all(16.w).copyWith(bottom: 12.w),
      decoration: BoxDecoration(
          color: ColorStyle.white,
          borderRadius: BorderRadius.all(Radius.circular(10.w))),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '积分记录',
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: ColorStyle.c333333),
              ),
              SizedBox(width: 10.w),
              Text(
                '显示最近6个月的积分记录',
                style: TextStyle(
                    fontSize: 12.sp,
                    color: ColorStyle.c333333.withOpacity(0.7)),
              )
            ],
          ),
          SizedBox(height: 5.w),
          Wrap(
            children: [
              ...controller.scoreDataList.map((e) {
                return _buildRunItemWidget(e);
              })
            ],
          )
        ],
      ),
    );
  }
}

