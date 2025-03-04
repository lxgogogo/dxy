import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/widget/background_container.dart';
import 'package:holdem/utils/toast_utils.dart';

import 'package:holdem/widget/search_bar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../gen/assets.gen.dart';
import '../../model/user.dart';
import '../../model/userdata_list.dart';
import '../../utils/app_theme.dart';
import '../../utils/size_fit.dart';
import '../../widget/follow_btn.dart';
import '../mine/login_helper.dart';

part 'at_user_controller.dart';

class AtUserScreen extends StatefulWidget {
  const AtUserScreen({Key? key}) : super(key: key);

  @override
  _AtUserScreenState createState() => _AtUserScreenState();
}

class _AtUserScreenState extends State<AtUserScreen> {
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
    return Container(
      margin: EdgeInsets.only(top: ScreenUtil().statusBarHeight),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
      ),
      child: contentView(),
    );
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
        // CSearchBar(
        //   placeholder: "搜索用户",
        //   onChanged: (value) {
        //     setState(() {
        //       key = value;
        //       _userSearch(key);
        //     });
        //   },
        // ),
        buildSearchInput(),
        SizedBox(
          height: 10,
        ),
        Expanded(child: listView())
      ],
    );
  }

  Widget buildSearchInput() {
    return Container(
      margin: EdgeInsets.only(left: 16.w, right: 16.w, top: 24.w, bottom: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              height: 32.w,
              padding: EdgeInsets.only(left: 12.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100.r),
                color: '#333333'.hexColor.withOpacity(0.05),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    Assets.svg.iconSearchHistory,
                    width: 16.w,
                    height: 16.w,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      onChanged: (value) {
                        setState(() {
                          key = value;
                          _userSearch(key);
                        });
                      },
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: '#333333'.hexColor,
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        hintText: '搜索用户',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isCollapsed: true,
                        isDense: true,
                        hintStyle: TextStyle(
                          fontSize: 12.sp,
                          color: '#333333'.hexColor.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                  if (searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: searchController.clear,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6.w),
                        child: Assets.images.clear.image(
                          width: 16.w,
                          height: 16.w,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(width: 16.w),
          GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Text(
              '取消',
              style: TextStyle(
                  color: '#557BF6'.hexColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600),
            ),
          )
        ],
      ),
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
          } else {
            if (userDataList.list!.length == 0) {
              ToastUtils.showToast("未搜到相关用户，请重新输入");
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
          Get.back(result: followOrFanUserList[index]);
        },
        child: Container(
          height: 58.px,
          margin: EdgeInsets.symmetric(horizontal: 18.px),
          alignment: Alignment.centerLeft,
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
              style: TextStyle(color: '##333333'.hexColor, fontSize: 14.px,fontWeight: FontWeight.w600),
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
