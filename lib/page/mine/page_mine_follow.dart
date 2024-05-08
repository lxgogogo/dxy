import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../utils/app_theme.dart';
import '../../utils/size_fit.dart';
import '../../view/forum/ToastUtils.dart';

class MineFollowPage extends StatefulWidget {
  MineFollowPage({Key? key}) : super(key: key);

  @override
  _MineFollowPageState createState() => _MineFollowPageState();
}

class CustomObject {
  String name;
  bool isFollowed;

  CustomObject(this.name, this.isFollowed);
}

class _MineFollowPageState extends State<MineFollowPage> {
  List<CustomObject> items = List.generate(7, (index) {
    return CustomObject('小小少年 $index', (index % 2 == 0 ? true : false));
  });

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  final TextEditingController searchController = TextEditingController();

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
    // items.add((items.length + 1).toString() as CustomObject);
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset(
            'assets/images/back.png',
            width: 22.px,
            height: 22.px,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        title: const Text(
          '我的关注',
          style: AppTheme.text333333Size17,
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            color: AppTheme.color_F3F3F3,
            thickness: 1,
          ),
        ),
      ),
      body: SafeArea(child: contentView()),
      backgroundColor: Colors.white,
    );
  }

  Widget contentView() {
    return Column(
      children: [
        Expanded(child: listView())
      ],
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

  Widget listDataItem(int index) {
    return Container(
      height: 45,
      margin: EdgeInsets.only(top: 10, bottom: 10),
      padding: EdgeInsets.fromLTRB(16, 0, 6, 0),
      child: Row(children: [
        Container(
            height: 45,
            child: Center(
                child: ClipOval(
              child: Image.network(
                'https://pic1.zhimg.com/80/v2-6545695ef3e3925dab264c68e54c23a0_1440w.webp',
                width: 45,
                height: 45,
                fit: BoxFit.cover,
              ),
            ))),
        SizedBox(
          width: 10,
        ),
        Text(
          items[index].name,
          style: AppTheme.text3B5078Size15,
        ),
        Expanded(child: Text('')),
        // items[index].isFollowed == true
        //     ? followedStatusBtn()
        //     :
        IconButton(
            onPressed: () {
              ToastUtils.showToast('已关注');
              // setState(() {
              //
              // });
            },
            icon: Image.asset(
              'assets/images/follow_btn.png',
              width: 62,
              height: 28,
            ))
      ]),
    );
  }

  Widget topSearchView() {
    return Container(
        height: 40,
        child: Center(
            child: Padding(
          padding: const EdgeInsets.only(left: 16,right: 16),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: '搜索用户',
              contentPadding: EdgeInsets.fromLTRB(0, 5, 0, 0),
              prefixIcon: IconButton(
                icon: Image.asset(
                  'assets/images/search_icon.png',
                  width: 15,
                  height: 15,
                ),
                onPressed: () {},
              ),
              suffixIcon: IconButton(
                icon: Image.asset(
                  'assets/images/search_clear.png',
                  width: 20,
                  height: 20,
                ),
                onPressed: () {
                  setState(() {
                    searchController.text = '';
                  });
                },
              ),
              filled: true,
              fillColor: AppTheme.color_EFEFEF,
              hintStyle: AppTheme.text999999Size14,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        )));
  }

  Widget followedStatusBtn() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.color_0D000000,
        borderRadius: BorderRadius.circular(25),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), // 设置内边距
      child: Text('已关注', style: AppTheme.text999999Size13),
    );
  }
}
