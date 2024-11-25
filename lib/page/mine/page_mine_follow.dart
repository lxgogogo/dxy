import 'package:flutter/material.dart';
import 'package:holdem/model/userdata_list.dart';
import 'package:holdem/model/user.dart';
import 'package:holdem/page/mine/login_helper.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/widget/background_container.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../utils/app_theme.dart';
import '../../utils/eventbus/EventBusAction.dart';
import '../../utils/eventbus/EventBusManager.dart';
import '../../utils/size_fit.dart';
import '../../view/forum/ToastUtils.dart';
import '../../widget/follow_btn.dart';

class MineFollowPage extends StatefulWidget {
  bool isFollowPage = true;

  MineFollowPage({Key? key, required this.isFollowPage}) : super(key: key);

  @override
  _MineFollowPageState createState() => _MineFollowPageState();
}

class _MineFollowPageState extends State<MineFollowPage> {
  int pageNum = 1;
  int pageSize = 10;
  bool isFollowPage = true;

  List<UserProfile> followOrFanUserList = [];
  bool _isMounted = false;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  final TextEditingController searchController = TextEditingController();

  void _onRefresh() async {
    setState(() {
      pageNum = 1;
    });
    reqListData();
  }

  void _onLoading() async {
    setState(() {
      pageNum++;
    });
    reqListData();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isMounted = true;
    isFollowPage = widget.isFollowPage;
    reqListData();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  reqListData() {
    if (isFollowPage) {
      NetRequest().followedList(pageNum.toString(), pageSize.toString(), '',
          (data) {
        UserDataList followOrFan = UserDataList.fromJson(data);
        if (_isMounted) {
          setState(() {
            if (pageNum == 1) {
              followOrFanUserList = followOrFan.list!;
            } else {
              followOrFanUserList.addAll(followOrFan.list!);
            }
          });
        }
        _refreshController.loadComplete();
        _refreshController.refreshCompleted();
      });
    } else {
      NetRequest().fansList(pageNum.toString(), pageSize.toString(), '',
          (data) {
        UserDataList followOrFan = UserDataList.fromJson(data);
        if (_isMounted) {
          setState(() {
            if (pageNum == 1) {
              followOrFanUserList = followOrFan.list!;
            } else {
              followOrFanUserList.addAll(followOrFan.list!);
            }
          });
        }
        _refreshController.loadComplete();
        _refreshController.refreshCompleted();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return BackgroundContainer(
        child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset(
            'assets/images/back.png',
            width: 22.px,
            height: 22.px,
          ),
          onPressed: () {
            //通知我的页面刷新关注粉丝数量
            EventBusManager.eventBus
                .fire(EventBusAction.refreshPersonalProfile.eventBusTypeName);
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        title: Text(
          isFollowPage ? '我的关注' : '我的粉丝',
          style: AppTheme.text333333Size17,
        ),
        centerTitle: true,
        // bottom: const PreferredSize(
        //   preferredSize: Size.fromHeight(1.0),
        //   child: Divider(
        //     color: AppTheme.color_F3F3F3,
        //     thickness: 1,
        //   ),
        // ),
      ),
      backgroundColor: Colors.transparent,
      body: SafeArea(
          child: Container(
              // color: Colors.red,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF4F7FC),
                  Color(0xFFE4EEF9),
                  Color(0xFFE4EEF9)
                ],
              )),
              child: contentView())),
    ));
  }

  Widget contentView() {
    return Center(
        child: Row(
      children: [
        Expanded(
            child: followOrFanUserList.isNotEmpty
                ? listView()
                : const NoDataView())
      ],
    ));
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
        itemCount: followOrFanUserList.length,
      ),
    );
  }

  Widget listDataItem(int index) {
    return Container(
      margin: EdgeInsets.only(left: 18.px,right:18.px),
      padding: EdgeInsets.only(top: 12.px,bottom: 12.px),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1.px,color: const Color(0xffE6E6E6)))),
      child: Row(children: [
        Container(
            height: 34.px,
            width: 34.px,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22.px),
                border: Border.all(color: Colors.white, width: 1)),
            child: Center(
                child: ClipOval(
              child: LoginHelper().getUserAvatar(
                  followOrFanUserList[index].avatar!.isNotEmpty
                      ? followOrFanUserList[index].avatar!
                      : '',
                  32.px,
                  32.px),
            ))),
        SizedBox(
          width: 7.px,
        ),
        Text(
          followOrFanUserList[index].nickname!.isNotEmpty
              ? followOrFanUserList[index].nickname!
              : '',
          style: TextStyle(color: const Color(0xff2a2a2a),fontSize: 12.px),
        ),
        const Spacer(),
        FollowBtn(
            isFollowed: followOrFanUserList[index].followed!,
            onTap: () {
              NetRequest().followerToggle(followOrFanUserList[index].id!,
                  !followOrFanUserList[index].followed!, (data) {
                if (_isMounted) {
                  setState(() {
                    if (isFollowPage) {
                      //关注页面移除当前条目
                      followOrFanUserList.remove(followOrFanUserList[index]);
                    } else {
                      //粉丝页面需要刷新状态
                      setState(() {
                        pageNum = 1;
                      });
                      reqListData();
                    }
                  });
                }
              });
            })
      ]),
    );
  }

  Widget topSearchView() {
    return Container(
        height: 40,
        child: Center(
            child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
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
                  if (_isMounted) {
                    setState(() {
                      searchController.text = '';
                    });
                  }
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
}
