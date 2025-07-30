import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/page/feed_list/widgets/feed_list_child.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/widget/keepalive_wrapper.dart';
import 'dart:math' as math;

import '../../gen/assets.gen.dart';
import '../../model/board_info.dart';
import '../../utils/track_utils.dart';
import '../../widget/common_operations_sheet.dart';

part 'feed_list_controller.dart';

class FeedListScreen extends StatefulWidget {
  const FeedListScreen({super.key});

  @override
  State<FeedListScreen> createState() => _FeedListScreenState();
}

class _FeedListScreenState extends State<FeedListScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  List<BoardInfo> boardInfoList = [];

  List<BoardInfo> get showBoardInfoList => [
        BoardInfo(id: 0, name: '全部'),
        ...boardInfoList,
      ];

  int selIndex = 0;

  StreamSubscription? eventSubscription;

  @override
  void initState() {
    super.initState();
    getPlateData();
    eventSubscription = EventBusUtil.of.on<EventRefreshFeedTabs>().listen((event) {
      getPlateData();
    });
  }

  @override
  void dispose() {
    eventSubscription?.cancel();
    super.dispose();
  }

  void getPlateData() {
    NetRequest().getBoardData(showLoading: false, (data) {
      List<BoardInfo> dataList = List<BoardInfo>.from(data.map((plate) => BoardInfo.fromJson(plate)));
      boardInfoList = dataList;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        toolbarHeight: 116.w - ScreenUtil().statusBarHeight,
        flexibleSpace: FlexibleSpaceBar(
          background: Image.asset(
            Assets.images.feedBg.path,
            fit: BoxFit.cover,
          ),
        ),
        // 设置导航条背景透明
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: detail(),
    );
  }

  Widget detail() {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 54.w,
              color: '#f7f8fc'.hexColor,
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(width: 16.w),
                    ...List.generate(showBoardInfoList.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          selIndex = index;
                          setState(() {});
                          final boardId = showBoardInfoList[selIndex].id ?? 0;
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 100),
                            curve: Curves.linear,
                          );
                          TrackUtils.trackEvent(
                            userLogType: '108001',
                            params: boardId,
                          );
                        },
                        child: Container(
                          height: 28.w,
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          margin: EdgeInsets.only(right: 12.w),
                          alignment: Alignment.center,
                          decoration: selIndex != index
                              ? ShapeDecoration(
                                  color: '#333333'.hexColor.withOpacity(0.05),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24.r),
                                  ),
                                )
                              : BoxDecoration(
                                  borderRadius: BorderRadius.circular(24.w),
                                  gradient: LinearGradient(
                                    colors: [
                                      '557BF6'.hexColor,
                                      '84BCF9'.hexColor,
                                    ],
                                  ),
                                ),
                          child: Text(
                            showBoardInfoList[index].name!,
                            style: TextStyle(
                              color: selIndex == index ? Colors.white : '#333333'.hexColor,
                              fontWeight: selIndex == index ? FontWeight.w600 : FontWeight.w400,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      );
                    })
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    color: Colors.white,
                  ),
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(showBoardInfoList.length, (index) {
                      return FeedListChildView(
                        boardId: showBoardInfoList[selIndex].id ?? 0,
                      ).keepAlive;
                    }).toList(),
                  )),
            )
          ],
        ),
        Positioned(
          right: 16.w,
          bottom: 84.w,
          child: GestureDetector(
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    '#557BF6'.hexColor,
                    '#84BCF9'.hexColor,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: '#58A5FF'.hexColor.withOpacity(0.2),
                    blurRadius: 10.r,
                    offset: Offset(0, 5.w),
                  )
                ],
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                Assets.svg.iconPostFeed,
                width: 20.w,
                height: 20.w,
              ),
            ),
            onTap: () {
              UserStore.of.checkLogin(() {
                Get.toNamed(Routes.feedPost, arguments: boardInfoList);
              });
            },
          ),
        ),
      ],
    );
  }
}
