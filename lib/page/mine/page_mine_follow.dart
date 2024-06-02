import 'package:flutter/material.dart';
import 'package:holdem/model/userdata_list.dart';
import 'package:holdem/model/user.dart';
import 'package:holdem/page/mine/login_helper.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../utils/app_theme.dart';
import '../../utils/eventbus/EventBusAction.dart';
import '../../utils/eventbus/EventBusManager.dart';
import '../../utils/size_fit.dart';
import '../../view/forum/ToastUtils.dart';
import '../../widget/follow_btn.dart';
import '../../widget/page_web_fit.dart';

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
    return WebFitPage(
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
        backgroundColor: Colors.white,
        title: Text(
          isFollowPage ? '我的关注' : '我的粉丝',
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
      height: 45,
      margin: EdgeInsets.only(top: 10, bottom: 10),
      padding: EdgeInsets.fromLTRB(16, 0, 6, 0),
      child: Row(children: [
        Container(
            height: 45,
            child: Center(
                child: ClipOval(
              child: LoginHelper().getUserAvatar(
                  followOrFanUserList[index].avatar!.isNotEmpty
                      ? followOrFanUserList[index].avatar!
                      : '',
                  45.px,
                  45.px),
            ))),
        SizedBox(
          width: 10,
        ),
        Text(
          followOrFanUserList[index].nickname!.isNotEmpty
              ? followOrFanUserList[index].nickname!
              : '',
          style: AppTheme.text3B5078Size15,
        ),
        Expanded(child: Text('')),
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
