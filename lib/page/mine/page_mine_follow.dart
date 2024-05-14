import 'package:flutter/material.dart';
import 'package:holdem/model/followed_list.dart';
import 'package:holdem/model/user.dart';
import 'package:holdem/page/mine/login_helper.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../utils/app_theme.dart';
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
    _isMounted =true;
    isFollowPage = widget.isFollowPage;
    getDataList();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  getDataList() {
    if (isFollowPage) {
      NetRequest()
          .followedList(pageNum.toString(), pageSize.toString(), '', (data) {
            if(_isMounted) {
              setState(() {
                FollowedList followOrFan = FollowedList.fromJson(data);
                followOrFanUserList = followOrFan.list!;
              });
            }
      });
    } else {
      NetRequest()
          .fansList(pageNum.toString(), pageSize.toString(), '', (data) {});
    }
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
    );
  }

  Widget contentView() {
    return Column(
      children: [Expanded(child: listView())],
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
                  ? followOrFanUserList[index].avatar! : '',45.px, 45.px),
            ))),
        SizedBox(
          width: 10,
        ),
        Text(
          followOrFanUserList[index].nickname!.isNotEmpty
              ? followOrFanUserList[index].nickname! : '',
          style: AppTheme.text3B5078Size15,
        ),
        Expanded(child: Text('')),
        // IconButton(
        //     onPressed: () {
        //       ToastUtils.showToast('已关注');
        //       // setState(() {
        //       //
        //       // });
        //     },
        //     icon: Image.asset(
        //       'assets/images/follow_btn.png',
        //       width: 62,
        //       height: 28,
        //     ))
        FollowBtn(isFollowed: followOrFanUserList[index].followed!, onTap:  () {

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
}
