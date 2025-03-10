import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/widget/background_container.dart';
import 'package:holdem/utils/toast_utils.dart';
import 'package:holdem/widget/no_data.dart';

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
  int pageSize = 20;

  List<UserProfile> followOrFanUserList = [];
  bool _isMounted = false;

  bool noMore = false;
  final RefreshController _refreshController = RefreshController();

  final TextEditingController searchController = TextEditingController();

  void _onRefresh() async {
    pageNum = 1;
    loadItems();
  }

  void _onLoading() async {
    pageNum++;
    loadItems();
  }

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _onRefresh();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.only(top: ScreenUtil().statusBarHeight),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
        ),
        child: Column(
          children: [
            buildSearchInput(),
            const SizedBox(
              height: 10,
            ),
            Expanded(child: listView())
          ],
        ),
      ),
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
                      onChanged: onSearch,
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
                      onTap: () {
                        searchController.clear();
                        _onRefresh();
                      },
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
              style: TextStyle(color: '#557BF6'.hexColor, fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
          )
        ],
      ),
    );
  }

  Future<void> loadItems() async {
    try {
      int recordsSize = 0;
      if (searchController.text.isNotEmpty) {
        await NetRequest().userSearch(pageNum, pageSize, searchController.text, (data) {
          UserDataList dataList = UserDataList.fromJson(data);
          recordsSize = dataList.list?.length ?? 0;
          if (pageNum == 1) {
            followOrFanUserList = dataList.list ?? [];
          } else {
            followOrFanUserList.addAll(dataList.list ?? []);
          }
        });
      } else {
        await NetRequest().followedList(pageNum.toString(), pageSize.toString(), '', (data) {
          UserDataList dataList = UserDataList.fromJson(data);
          recordsSize = dataList.list?.length ?? 0;
          if (pageNum == 1) {
            followOrFanUserList = dataList.list ?? [];
          } else {
            followOrFanUserList.addAll(dataList.list ?? []);
          }
        });
      }
      if (pageNum == 1) {
        _refreshController.refreshCompleted();
        if (recordsSize < pageSize) {
          noMore = true;
          _refreshController.loadNoData();
        } else {
          noMore = false;
          _refreshController.resetNoData();
        }
      } else {
        if (recordsSize < pageSize) {
          noMore = true;
          _refreshController.loadNoData();
        } else {
          noMore = false;
          _refreshController.loadComplete();
        }
      }
    } finally {
      setState(() {});
    }
  }

  void onSearch(String keyword) {
    _onRefresh();
  }

  ///列表数据
  Widget listView() {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: followOrFanUserList.isNotEmpty
          ? ListView.builder(
              itemBuilder: (c, i) => listDataItem(i),
              itemCount: followOrFanUserList.length,
            )
          : const NoDataView(),
    );
  }

  Widget listDataItem(int index) {
    return GestureDetector(
        onTap: () {
          Get.back(result: followOrFanUserList[index]);
        },
        child: Container(
          height: 58.w,
          margin: EdgeInsets.symmetric(horizontal: 18.w),
          alignment: Alignment.centerLeft,
          child: Row(children: [
            Container(
                height: 34.w,
                width: 34.w,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(17.w), color: Colors.white),
                child: Center(
                    child: ClipOval(
                  child: LoginHelper().getUserAvatar(
                      followOrFanUserList[index].avatar!.isNotEmpty ? followOrFanUserList[index].avatar! : '',
                      32.w,
                      32.w),
                ))),
            SizedBox(
              width: 10.w,
            ),
            Text(
              followOrFanUserList[index].nickname!.isNotEmpty ? followOrFanUserList[index].nickname! : '',
              style: TextStyle(color: '##333333'.hexColor, fontSize: 14.w, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            FollowBtn(
                isFollowed: followOrFanUserList[index].followed!,
                onTap: () {
                  NetRequest().followerToggle(followOrFanUserList[index].id!, !followOrFanUserList[index].followed!,
                      (data) {
                    followOrFanUserList[index].followed = !followOrFanUserList[index].followed!;
                    if (mounted) {
                      setState(() {});
                    }
                  });
                })
          ]),
        ));
  }
}
