import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/route_manager.dart';
import 'package:holdem/page/index/page_book_detail.dart';
import 'package:holdem/page/index/page_search.dart';
import 'package:holdem/page/index/page_video_list.dart';
import 'package:holdem/utils/constants.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  int _currentTabIndex = 0;
  final List<String> tabs = ['资讯', '视频', '书籍', '教程'];

  List<String> items = ["1", "2", "3", "4", "5", "6", "7", "8"];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);


      @override
  void initState() {
    super.initState();
    NetRequest().getBoardList();
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    items.add((items.length + 1).toString());
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return Scaffold(
      extendBodyBehindAppBar: true, // 将导航条扩展到背景图片后面
      backgroundColor: kBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 设置导航条背景透明
        elevation: 0, // 去除导航条的阴影
        title: Row(
          children: [
            ...List<Widget>.generate(tabs.length, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentTabIndex = index;
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(right: 23.px),
                  child: Column(
                    children: [
                      Text(tabs[index],
                          style: TextStyle(
                              color: _currentTabIndex == index
                                  ? Color(0xff008EFF)
                                  : Color(0xff647A9C),
                              fontWeight: FontWeight.bold,
                              fontSize: 16.px)),
                      _currentTabIndex == index
                          ? Image.asset('assets/images/tab_sel.png',
                              width: 30.px, height: 6.px)
                          : Container(),
                    ],
                  ),
                ),
              );
            })
          ],
        ),
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/images/navi_search.png',
              width: 35.px,
              height: 38.px,
            ),
            onPressed: () {
              // 登录按钮点击事件
              Get.to(SearchPage());
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/home_top.png', // 替换为你的图片路径
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Colors.transparent, // 设置背景颜色为灰色
            child: Column(
              children: [
                SafeArea(
                    child: SizedBox(
                  height: 0.px,
                )),
                Expanded(child: _currentTabIndex == 2 ? gridView() : listView())
              ],
            ),
          ),
        ],
      ),
    );
  }

  ///列表数据
  Widget listView() {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropHeader(),
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: ListView.builder(
        itemBuilder: (c, i) => listDataItem(i),
        // itemExtent: 160.0,
        itemCount: items.length,
      ),
    );
  }

  Widget gridView() {
    return SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: WaterDropHeader(),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 12.px),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: 8.px,
            mainAxisSpacing: 8.px,
          ),
          itemBuilder: (c, i) => bookItem(i),
          itemCount: items.length,
        ));
  }

  Widget bookItem(int index) {
    return GestureDetector(
      onTap: (){
        Get.to(const BookDetailPage());
      },
      child: Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10.px))),
      child: Column(
        children: [
          Image.network(
            'https://pic1.zhimg.com/80/v2-6545695ef3e3925dab264c68e54c23a0_1440w.webp',
            width: 171.px,
            height: 145.px,
            fit: BoxFit.cover,
          ),
          Expanded(
              child: Container(
            padding: EdgeInsets.all(10.px),
            child: Text(
              'ELKY当今德州锦标赛打法转行德扑的…',
              maxLines: 2,
              style: TextStyle(color: Color(0xff3B5078)),
            ),
          ))
        ],
      ),
    ),);
  }

  Widget listDataItem(int index) {
    return GestureDetector(
      onTap: (){
        Get.to(VideoListPage());
      },
      child: Container(
        padding: EdgeInsets.all(12.px),
        margin: EdgeInsets.only(top: 10.px, left: 16.px, right: 16.px),
        decoration: BoxDecoration(
          //flutter 上下颜色渐变
          //#F9CF3A, #FFD43E00
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEEF7FE),
              Color(0xFFFFFFFF),
              // Color.fromRGBO(140, 190, 233, 1),
              // Color.fromRGBO(190, 214, 235, 1),
              // Color.fromRGBO(140, 190, 233, 1),
              // Color.fromRGBO(194, 216, 235, 1),
              // Color.fromRGBO(140, 190, 233, 1),
              // Color.fromRGBO(193, 215, 235, 1),
              // Color.fromRGBO(140, 190, 233, 1),
            ],
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.white,
              blurRadius: 4.0,
              spreadRadius: -4.0,
              offset: Offset(0.0, 6.0),
            ),
            // BoxShadow(
            //   color: Color.fromRGBO(148, 197, 239, 0.74),
            //   blurRadius: 9.4,
            //   spreadRadius: -9.4,
            //   offset: Offset(0.0, -4.0),
            // )
          ],
          borderRadius: BorderRadius.all(Radius.circular(13.px)),
        ),
        child: Row(
          children: [
            Container(
              width: 145.px,
              height: 120.px,
              margin: EdgeInsets.only(right: 15.px),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8.px)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                'https://pic1.zhimg.com/80/v2-6545695ef3e3925dab264c68e54c23a0_1440w.webp',
                width: 145.px,
                height: 120.px,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
                child: SizedBox(
              height: 120.px,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    '阿丽塔概念设计图曝光 女主身体内部如同艺术品',
                    maxLines: 3,
                    style: TextStyle(
                      color: const Color(0xff3B5078),
                      fontSize: 16.px,
                    ),
                  ),
                  // Spacer(),
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/time.png',
                        width: 20.px,
                        height: 20.px,
                      ),
                      SizedBox(
                        width: 5.px,
                      ),
                      Text(
                        '13:00',
                        style: TextStyle(
                          color: const Color(0xff666666),
                          fontSize: 14.px,
                        ),
                      ),
                      SizedBox(
                        width: 30.px,
                      ),
                      Image.asset(
                        'assets/images/comment.png',
                        width: 20.px,
                        height: 20.px,
                      ),
                      SizedBox(
                        width: 5.px,
                      ),
                      Text(
                        '16',
                        style: TextStyle(
                          color: const Color(0xff666666),
                          fontSize: 14.px,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ))
          ],
        )),);
  }
}
