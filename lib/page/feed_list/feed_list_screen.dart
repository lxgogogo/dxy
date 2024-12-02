import 'package:dynamic_tabbar/dynamic_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/page/feed_list/widgets/feed_list_child.dart';
import 'package:holdem/page/feed_post/feed_post_screen.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/background_container.dart';
import 'package:super_tooltip/super_tooltip.dart';

import '../../model/board_info.dart';
import '../../utils/constants.dart';
import '../../utils/eventbus/EventBusAction.dart';
import '../../utils/eventbus/EventBusManager.dart';
import '../../utils/global.dart';
import '../login/login_screen.dart';

part 'feed_list_controller.dart';

class FeedListScreen extends StatefulWidget {
  const FeedListScreen({super.key});

  @override
  State<FeedListScreen> createState() => _FeedListScreenState();
}

class _FeedListScreenState extends State<FeedListScreen> with SingleTickerProviderStateMixin {
  late int currentBoardId = 0;
  late List<BoardInfo> boardInfoList;
  int selIndex = 0;

  SuperTooltipController _tipController = SuperTooltipController();
  List<String> filters = [
    '时间最新',
    '回帖最多',
    '点赞最多',
  ];
  int filterIndex = 0;

  String get filterValue => filters[selIndex];

  final _pageKey = GlobalKey<ForumTabChildPageState>();

  //默认全部板块
  List<TabData> forumParentTabs = [
    TabData(
      index: 0,
      title: const Tab(
        child: Text('全部板块'),
      ),
      content: ForumTabChildPage(tabId: 0),
    )
  ];

  @override
  void initState() {
    super.initState();
    boardInfoList = [];
    getPlateData();
    EventBusManager.eventBus.on().listen((event) {
      if (event.toString() == EventBusAction.updateBoardTabData.eventBusTypeName) {
        if (mounted) {
          getPlateData();
        }
      }
    });
  }

  void getPlateData() {
    NetRequest().getBoardData((data) {
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
    return BackgroundContainer(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '论坛',
            style: TextStyle(
              color: const Color(0xff2c2c2c),
              fontSize: 16.w,
              fontWeight: FontWeight.w500,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          // 设置导航条背景透明
          elevation: 0,
          actions: [
            SuperTooltip(
              showBarrier: true,
              controller: _tipController,
              popupDirection: TooltipDirection.down,
              backgroundColor: Colors.transparent,
              hasShadow: false,
              borderColor: Colors.transparent,
              arrowLength: 0,
              arrowTipDistance: 21.25.w,
              bubbleDimensions: EdgeInsets.zero,
              touchThroughAreaShape: ClipAreaShape.rectangle,
              touchThroughAreaCornerRadius: 10,
              minimumOutsideMargin: 0,
              barrierColor: Colors.transparent,
              right: 16.w,
              content: Container(
                width: 90.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10.r)),
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
                            color: filterIndex == index ? const Color(0xff249cfc) : const Color(0xff95a3c4),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => Container(
                    color: const Color(0xffe7f0fa),
                    height: 0.5,
                  ),
                ),
              ),
              child: UnconstrainedBox(
                child: IconButton(
                  icon: Image.asset(
                    'assets/images/order.png',
                    width: 20.w,
                    height: 20.w,
                  ),
                  onPressed: () {
                    _tipController.showTooltip();
                  },
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        body: detail(),
        floatingActionButton: bottomFloatingButton(),
      ),
    );
  }

  Widget detail() {
    int tabId = 0;
    if (selIndex != 0) {
      tabId = boardInfoList[selIndex - 1].id!;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
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
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.w),
                      border: selIndex == 0 ? null : Border.all(color: const Color(0xffffffff).withOpacity(0.7)),
                      boxShadow: [
                        BoxShadow(
                          color: selIndex == 0 ? const Color(0xFFC8D4EE) : const Color(0xFFd6e2f0),
                          spreadRadius: 0,
                          blurRadius: 10,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: selIndex == 0
                            ? const [
                                Color(0xFF75BFFF),
                                Color(0xFF48AAFF),
                                Color(0xFF479DFF),
                                Color(0xFF3B91F1),
                              ]
                            : const [
                                Color(0xFFF5F8FF),
                                Color(0xFFECF3FF),
                              ],
                      )),
                  child: Text(
                    '全部',
                    style: TextStyle(color: selIndex == 0 ? Colors.white : const Color(0xff95A3C4), fontSize: 14.w),
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
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.w),
                        border:
                            selIndex == index + 1 ? null : Border.all(color: const Color(0xffffffff).withOpacity(0.7)),
                        boxShadow: [
                          BoxShadow(
                            color: selIndex == index + 1 ? const Color(0xFFC8D4EE) : const Color(0xFFd6e2f0),
                            spreadRadius: 0,
                            blurRadius: 10,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: selIndex == index + 1
                              ? const [
                                  Color(0xFF75BFFF),
                                  Color(0xFF48AAFF),
                                  Color(0xFF479DFF),
                                  Color(0xFF3B91F1),
                                ]
                              : const [
                                  Color(0xFFF5F8FF),
                                  Color(0xFFECF3FF),
                                ],
                        )),
                    child: Text(
                      boardInfoList[index].name!,
                      style: TextStyle(
                          color: selIndex == index + 1 ? Colors.white : const Color(0xff95A3C4), fontSize: 14.w),
                    ),
                  ),
                );
              })
            ],
          ),
        ),
        Expanded(
            child: ForumTabChildPage(
          tabId: tabId,
          key: _pageKey,
        ))
      ],
    );
  }

  ///底部FloatingButton
  Widget bottomFloatingButton() {
    return IconButton(
      padding: EdgeInsets.zero,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      icon: Image.asset(
        'assets/images/posting_btn.png',
        width: 58.w,
        height: 58.w,
      ),
      // backgroundColor: Colors.transparent,
      onPressed: () {
        Global().checkLogin(() {
          Get.toNamed(Routes.feedPost, arguments: boardInfoList);
        });
      },
      // shape: CircleBorder(),
    );
  }
}
