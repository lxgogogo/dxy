import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:holdem/page/index/page_video_detail.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class VideoListPage extends StatefulWidget {
  const VideoListPage({super.key});

  @override
  State<VideoListPage> createState() => _VideoListPageState();
}

class _VideoListPageState extends State<VideoListPage> {
  List<String> items = ["1", "2", "3", "4", "5", "6", "7", "8"];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

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
        // extendBodyBehindAppBar: true, // 将导航条扩展到背景图片后面
        appBar: AppBar(
          title: Text('视频合集列表'),
        ),
        body: content());
  }

  Widget content() {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropHeader(),
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: ListView.builder(
        itemBuilder: (c, i) => videoDataItem(i),
        // itemExtent: 160.0,
        itemCount: items.length,
      ),
    );
  }

  Widget videoDataItem(int index) {
    return GestureDetector(
      onTap: () {
        Get.to(const VideoDetailPage());
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.px),
        margin: EdgeInsets.symmetric(horizontal: 10.px),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(width: 1.px, color: Color(0xffe5e5e5)))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(5.px),
                child: Image.network(
                  'https://pic1.zhimg.com/80/v2-6545695ef3e3925dab264c68e54c23a0_1440w.webp',
                  width: 160.px,
                  height: 90.px,
                  fit: BoxFit.cover,
                )),
            SizedBox(
              width: 12.px,
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '无限德州理论与实践无限德州理论与实践 1',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis, // 超出显示省略号
                  style: TextStyle(
                      color: Color(0xff3B5078),
                      fontSize: 15.px,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 6.px,
                ),
                Text(
                  '2022-02-01',
                  style: TextStyle(color: Color(0xff666666), fontSize: 12.px),
                ),
                SizedBox(
                  height: 10.px,
                ),
                Row(
                  children: [
                    Image.asset(
                      'assets/images/eye.png',
                      width: 20.px,
                      height: 20.px,
                    ),
                    SizedBox(
                      width: 5.px,
                    ),
                    Text(
                      '1300',
                      style: TextStyle(
                        color: const Color(0xff999999),
                        fontSize: 14.px,
                      ),
                    ),
                    SizedBox(
                      width: 30.px,
                    ),
                    Image.asset(
                      'assets/images/praise.png',
                      width: 18.px,
                      height: 18.px,
                    ),
                    SizedBox(
                      width: 5.px,
                    ),
                    Text(
                      '16',
                      style: TextStyle(
                        color: const Color(0xff999999),
                        fontSize: 14.px,
                      ),
                    )
                  ],
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}
