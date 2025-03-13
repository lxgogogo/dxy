import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/page/feed_list/widgets/feed_list_child.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/widget/background_container.dart';
import 'package:super_tooltip/super_tooltip.dart';

import '../../gen/assets.gen.dart';
import '../../model/board_info.dart';
import '../../utils/eventbus/EventBusAction.dart';
import '../../utils/eventbus/EventBusManager.dart';

part 'feed_list_controller.dart';

class FeedListScreen extends StatefulWidget {
  const FeedListScreen({super.key});

  @override
  State<FeedListScreen> createState() => _FeedListScreenState();
}

class _FeedListScreenState extends State<FeedListScreen> with SingleTickerProviderStateMixin {
  int currentBoardId = 0;
  List<BoardInfo> boardInfoList = [];
  int selIndex = 0;

  SuperTooltipController _tipController = SuperTooltipController();
  List<String> filters = [
    '时间最新',
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
        setState(() {
          boardInfoList = dataList;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        toolbarHeight: 100,
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
    int tabId = 0;
    if (selIndex != 0) {
      tabId = boardInfoList[selIndex - 1].id!;
    }
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                height: 54.w,
                color: '#f7f8fc'.hexColor,
                alignment: Alignment.bottomLeft,
                child: Row(
                  children: [
                    SizedBox(
                      width: 18.w,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selIndex = 0;
                        });
                        String order = filterIndex == 0
                            ? 'time'
                            : filterIndex == 1
                                ? 'comment'
                                : 'like';
                        _pageKey.currentState?.refreshData(0, order);
                      },
                      child: Container(
                        height: 30.w,
                        padding: EdgeInsets.symmetric(horizontal: 17.w),
                        margin: EdgeInsets.only(right: 12.w, bottom: 12.w),
                        alignment: Alignment.center,
                        decoration: selIndex != 0
                            ? ShapeDecoration(
                                color: '#edeef2'.hexColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              )
                            : BoxDecoration(
                                borderRadius: BorderRadius.circular(24.w),
                                gradient: const LinearGradient(
                                  begin: Alignment(1.00, 0.00),
                                  end: Alignment(-1, 0),
                                  colors: [
                                    Color(0xFF84BCF9),
                                    Color(0xFF557BF6),
                                  ],
                                ),
                              ),
                        child: Text(
                          '全部',
                          style: TextStyle(
                              color: selIndex == 0 ? Colors.white : '#6f6f70'.hexColor,
                              fontWeight: selIndex == 0 ? FontWeight.w600 : FontWeight.w500,
                              fontSize: 12),
                        ),
                      ),
                    ),
                    ...List.generate(boardInfoList.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selIndex = index + 1;
                          });
                          String order = filterIndex == 0
                              ? 'time'
                              : filterIndex == 1
                                  ? 'comment'
                                  : 'like';
                          _pageKey.currentState?.refreshData(boardInfoList[selIndex - 1].id!, order);
                        },
                        child: Container(
                          height: 30.w,
                          padding: EdgeInsets.symmetric(horizontal: 17.w),
                          margin: EdgeInsets.only(right: 12.w, bottom: 12.w),
                          alignment: Alignment.center,
                          decoration: selIndex != index + 1
                              ? ShapeDecoration(
                                  color: '#edeef2'.hexColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                )
                              : BoxDecoration(
                                  borderRadius: BorderRadius.circular(24.w),
                                  gradient: const LinearGradient(
                                    begin: Alignment(1.00, 0.00),
                                    end: Alignment(-1, 0),
                                    colors: [
                                      Color(0xFF84BCF9),
                                      Color(0xFF557BF6),
                                    ],
                                  ),
                                ),
                          child: Text(
                            boardInfoList[index].name!,
                            style: TextStyle(
                                color: selIndex == index + 1 ? Colors.white : '#6f6f70'.hexColor,
                                fontWeight: selIndex == index + 1 ? FontWeight.w600 : FontWeight.w500,
                                fontSize: 12),
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
                                    _pageKey.currentState?.refreshData(0, order);
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
                          onTap: () {
                            _tipController.showTooltip();
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  filters[filterIndex],
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: '#333333'.hexColor.withOpacity(0.8),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_drop_down_outlined,
                                  color: '#333333'.hexColor.withOpacity(0.8),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 12.w,
                    ),
                    Expanded(
                        child: FeedListChildView(
                          tabId: tabId,
                          key: _pageKey,
                        )),
                  ],
                )
              ),
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
