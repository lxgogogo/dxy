import 'package:flutter/material.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/widget/page_web_fit.dart';
import 'package:holdem/widget/search_bar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../model/user.dart';
import '../../model/userdata_list.dart';
import '../../utils/app_theme.dart';
import '../../utils/size_fit.dart';
import '../../widget/follow_btn.dart';
import '../mine/login_helper.dart';

class AitUserPage extends StatefulWidget {
  AitUserPage({Key? key}) : super(key: key);

  @override
  _AitUserPageState createState() => _AitUserPageState();
}

class _AitUserPageState extends State<AitUserPage> {
  int pageNum = 1;
  int pageSize = 10;
  late String key;

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
    reqListData();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  reqListData() {
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
              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.transparent,
          title: CSearchBar(
            onChanged: (value) {
              setState(() {
                key = value;
              });
            },
          ),
          // title: const Text(
          //   '想@谁',
          //   style: AppTheme.text333333Size17,
          // ),
          centerTitle: true,
          actions: [
            TextButton(
                onPressed: () {
                  if (key != null) {
                    _userSearch(key);
                    // StorageUtil().prefs!.setString('token', data['token']);
                  }
                },
                child: Text('搜索',
                    style: TextStyle(
                        color: const Color(0xff249CFC), fontSize: 15.px)))
            // GestureDetector(child: Text('搜索'),)
          ]),
      body: SafeArea(child: contentView()),
      backgroundColor: const Color(0xffE8F3FF),
    ));
  }

  Widget contentView() {
    return Column(
      children: [
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     Expanded(child: topSearchView()),
        //     GestureDetector(
        //       child: Container(
        //           margin: EdgeInsets.only(right: 16),
        //           child: Text(
        //             '搜索',
        //             style: TextStyle(
        //                 color: const Color(0xff249CFC), fontSize: 15.px),
        //           )),
        //       onTap: () {
        //         _userSearch(key);
        //       },
        //     )
        //   ],
        // ),
        SizedBox(
          height: 10,
        ),
        Expanded(child: listView())
      ],
    );
  }

  void _userSearch(keyword) {
    //请求搜索关键字的用户列表   清空原有列表
    NetRequest().userSearch(pageNum, pageSize, keyword, (data) {
      UserDataList userDataList = UserDataList.fromJson(data);
      if (_isMounted) {
        setState(() {
          followOrFanUserList.clear();
          if (userDataList.list!.isNotEmpty && userDataList.list!.length > 0) {
            if (pageNum == 1) {
              followOrFanUserList = userDataList.list!;
            } else {
              followOrFanUserList.addAll(userDataList.list!);
            }
          }
        });
        _refreshController.loadComplete();
        _refreshController.refreshCompleted();
      }
    });
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
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.px),
                topRight: Radius.circular(12.px)),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF6FBFF),
                Color(0xFFE8F3FF),
              ],
            )),
        child: ListView.builder(
          itemBuilder: (c, i) => listDataItem(i),
          // itemExtent: 160.0,
          itemCount: followOrFanUserList.length,
        ),
      ),
    );
  }

  Widget listDataItem(int index) {
    return GestureDetector(
        onTap: () {
          print('===================' + followOrFanUserList[index].nickname!);
          Navigator.pop(context, followOrFanUserList[index]);
        },
        child: Container(
          height: 58.px,
          margin: EdgeInsets.symmetric(horizontal: 18.px),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              border: Border(
                  bottom:
                      BorderSide(color: const Color(0xffE6E6E6), width: 1.px))),
          child: Row(children: [
            Container(
                height: 34.px,
                width: 34.px,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(17.px),
                    color: Color(0xeeffffff)),
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
              width: 10.px,
            ),
            Text(
              followOrFanUserList[index].nickname!.isNotEmpty
                  ? followOrFanUserList[index].nickname!
                  : '',
              style: TextStyle(color: const Color(0xff2A2A2A), fontSize: 12.px),
            ),
            const Spacer(),
            FollowBtn(
                isFollowed: followOrFanUserList[index].followed!,
                onTap: () {
                  NetRequest().followerToggle(followOrFanUserList[index].id!,
                      !followOrFanUserList[index].followed!, (data) {
                    if (mounted) {
                      setState(() {
                        followOrFanUserList.remove(followOrFanUserList[index]);
                      });
                    }
                  });
                })
          ]),
        ));
  }

  Widget topSearchView() {
    return Container(
        height: 40.px,
        child: Center(
            child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: '搜索用户',
              contentPadding: EdgeInsets.fromLTRB(-3, 5, 0, 0),
              prefixIcon: IconButton(
                icon: Image.asset(
                  'assets/images/search_icon.png',
                  width: 15.px,
                  height: 15.px,
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
                    //重新刷新原有未搜索列表
                    if (followOrFanUserList.isNotEmpty) {
                      followOrFanUserList.clear();
                    }
                    reqListData();
                  }
                },
              ),
              filled: true,
              fillColor: AppTheme.color_EFEFEF,
              hintStyle: AppTheme.text999999Size15,
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
