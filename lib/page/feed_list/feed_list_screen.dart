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
import 'package:super_tooltip/super_tooltip.dart';

import '../../gen/assets.gen.dart';
import '../../model/board_info.dart';
import '../../utils/track_utils.dart';

part 'feed_list_controller.dart';

class FeedListScreen extends StatefulWidget {
  const FeedListScreen({super.key});

  @override
  State<FeedListScreen> createState() => _FeedListScreenState();
}

class _FeedListScreenState extends State<FeedListScreen> with SingleTickerProviderStateMixin {
  List<BoardInfo> boardInfoList = [];

  List<BoardInfo> get showBoardInfoList => [
        BoardInfo(id: 0, name: '全部'),
        ...boardInfoList,
      ];

  int selIndex = 0;

  final SuperTooltipController _tipController = SuperTooltipController();
  List<String> filters = [
    '最近更新',
    '回帖最多',
    '点赞最多',
  ];
  int filterIndex = 0;

  final _pageKey = GlobalKey<FeedListChildViewState>();

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
      if (mounted) {
        boardInfoList = dataList;
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
                          final order = filterIndex == 0
                              ? 'time'
                              : filterIndex == 1
                                  ? 'comment'
                                  : 'like';
                          final boardId = showBoardInfoList[selIndex].id;
                          if (boardId == null) return;
                          _pageKey.currentState?.refreshData(
                            boardId,
                            order,
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
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: SuperTooltip(
                          showBarrier: true,
                          controller: _tipController,
                          popupDirection: TooltipDirection.down,
                          backgroundColor: Colors.transparent,
                          hasShadow: false,
                          borderColor: Colors.transparent,
                          arrowLength: 0,
                          arrowTipDistance: 21.w,
                          bubbleDimensions: EdgeInsets.zero,
                          touchThroughAreaShape: ClipAreaShape.rectangle,
                          touchThroughAreaCornerRadius: 10,
                          minimumOutsideMargin: 0,
                          barrierColor: Colors.transparent,
                          right: 18.w,
                          content: Container(
                            width: 72.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(6.r)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10.r,
                                  offset: Offset(0, 5.w),
                                ),
                                BoxShadow(
                                  color: const Color(0xfffafcff),
                                  blurRadius: 1.r,
                                  spreadRadius: -1.r,
                                  offset: Offset(0, -1.w),
                                ),
                              ],
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: filters.length,
                              padding: EdgeInsets.zero,
                              itemBuilder: (BuildContext context, int index) {
                                final item = filters[index];
                                return GestureDetector(
                                  onTap: () {
                                    _tipController.hideTooltip();
                                    if (filterIndex != index) {
                                      filterIndex = index;
                                      String order = filterIndex == 0
                                          ? 'time'
                                          : filterIndex == 1
                                              ? 'comment'
                                              : 'like';
                                      _pageKey.currentState?.refreshFilter(order);
                                    }
                                  },
                                  child: Container(
                                    height: 41.5.w,
                                    alignment: Alignment.center,
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                        color: '#333333'.hexColor,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (_, __) => Container(
                                margin: EdgeInsets.symmetric(horizontal: 12.w),
                                color: '#333333'.hexColor.withOpacity(0.1),
                                height: 1.w,
                              ),
                            ),
                          ),
                          child: GestureDetector(
                            onTap: _tipController.showTooltip,
                            child: Padding(
                              padding: EdgeInsets.all(12.w),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    filters[filterIndex],
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: '#666666'.hexColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  SvgPicture.asset(
                                    Assets.svg.arrowDown,
                                    width: 10.w,
                                    height: 10.w,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(child: FeedListChildView(key: _pageKey)),
                    ],
                  )),
            )
          ],
        ),
        Positioned(
          right: 0,
          bottom: kBottomNavigationBarHeight + ScreenUtil().bottomBarHeight + 8.w,
          child: GestureDetector(
            child: Assets.images.iconPostFeed.image(width: 64.w),
            onTap: () {
              UserStore.of.checkLogin(() {
                Get.toNamed(Routes.feedPost, arguments: boardInfoList);
              });
            },
            // shape: CircleBorder(),
          ),
        ),
      ],
    );
  }
}
