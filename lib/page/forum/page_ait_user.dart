import 'package:flutter/material.dart';
import 'package:holdem/utils/net_request.dart';
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
          '想@谁',
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: topSearchView()),
            GestureDetector(
              child: Container(
                  margin: EdgeInsets.only(right: 16),
                  child: Text(
                    '搜索',
                    style: AppTheme.text3B5078Size15,
                  )),
              onTap: () {
                _userSearch();
              },
            )
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Expanded(child: listView())
      ],
    );
  }

  void _userSearch() {
    print('search text==>${searchController.text}');
    if (searchController.text.isEmpty) {
      return;
    }
    //请求搜索关键字的用户列表   清空原有列表
    NetRequest().userSearch(pageNum, pageSize, searchController.text, (data) {
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
      child: ListView.builder(
        itemBuilder: (c, i) => listDataItem(i),
        // itemExtent: 160.0,
        itemCount: followOrFanUserList.length,
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
          height: 45,
          margin: EdgeInsets.only(top: 10, bottom: 10),
          padding: EdgeInsets.fromLTRB(16, 0, 6, 0),
          child: Row(children: [
            Container(
                height: 45.px,
                width: 45.px,
                child: Center(
                    child: ClipOval(
                  child: LoginHelper().getUserAvatar(
                      followOrFanUserList[index].avatar!.isNotEmpty
                          ? followOrFanUserList[index].avatar!
                          : '',
                      45,
                      45),
                ))),
            SizedBox(
              width: 5,
            ),
            Text(
              followOrFanUserList[index].nickname!.isNotEmpty
                  ? followOrFanUserList[index].nickname!
                  : '',
              style: AppTheme.text3B5078Size15,
            ),
            Expanded(child: Text('')),
            FollowBtn(
                isFollowed: followOrFanUserList[index].followed!, onTap: () {
              NetRequest().followerToggle(followOrFanUserList[index].id!,
                  !followOrFanUserList[index].followed!, (data) {
                    setState(() {
                      followOrFanUserList.remove(followOrFanUserList[index]);
                    });
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
