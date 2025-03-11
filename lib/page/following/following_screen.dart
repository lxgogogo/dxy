import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
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
import '../../utils/toast_utils.dart';
import '../../widget/follow_btn.dart';

part 'following_controller.dart';

class FollowingScreen extends StatefulWidget {
  final bool isFollowPage;

  const FollowingScreen({Key? key, required this.isFollowPage}) : super(key: key);

  @override
  _FollowingScreenState createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  int pageNum = 1;
  int pageSize = 10;
  bool isFollowPage = true;

  List<UserProfile> items = [];
  bool _isMounted = false;

  final RefreshController _refreshController = RefreshController();

  final TextEditingController searchController = TextEditingController();

  void _onRefresh() async {
    pageNum = 1;
    reqListData();
  }

  void _onLoading() async {
    pageNum++;
    reqListData();
  }

  @override
  void initState() {
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
      NetRequest().followedList(pageNum.toString(), pageSize.toString(), '', (data) {
        UserDataList followOrFan = UserDataList.fromJson(data);
        if (_isMounted) {
          setState(() {
            if (pageNum == 1) {
              items = followOrFan.list!;
            } else {
              items.addAll(followOrFan.list!);
            }
          });
        }
        _refreshController.loadComplete();
        _refreshController.refreshCompleted();
      });
    } else {
      NetRequest().fansList(pageNum.toString(), pageSize.toString(), '', (data) {
        UserDataList followOrFan = UserDataList.fromJson(data);
        if (_isMounted) {
          setState(() {
            if (pageNum == 1) {
              items = followOrFan.list!;
            } else {
              items.addAll(followOrFan.list!);
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset(
            'assets/images/back.png',
            width: 22.w,
            height: 22.w,
          ),
          onPressed: () {
            EventBusManager.eventBus.fire(EventBusAction.refreshPersonalProfile.eventBusTypeName);
            Get.back();
          },
        ),
        backgroundColor: Colors.transparent,
        title: Text(
          isFollowPage ? '我的关注' : '我的粉丝',
          style: AppTheme.text333333Size17,
        ),
        centerTitle: true,
      ),
      backgroundColor: '#F7F8FC'.hexColor,
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: items.isNotEmpty
            ? ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.w),
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      ClipOval(
                        child: CachedNetworkImage(
                          width: 36.w,
                          height: 36.w,
                          fit: BoxFit.cover,
                          imageUrl: items[index].avatar ?? '',
                          errorWidget: (context, url, error) => Image.asset('assets/images/default_avatar.png'),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: Text(
                            items[index].nickname ?? '',
                            style: TextStyle(
                              color: '#333333'.hexColor,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          NetRequest().followerToggle(
                            items[index].id!,
                            !items[index].followed!,
                            (data) {
                              if (isFollowPage) {
                                items.removeAt(index);
                                ToastUtils.showToast('取消关注成功');
                                if (_isMounted) {
                                  setState(() {});
                                }
                              } else {
                                pageNum = 1;
                                reqListData();
                              }
                            },
                          );
                        },
                        child: Container(
                          width: 70.w,
                          height: 28.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: items[index].followed == true
                                ? '#EBEBEB'.hexColor
                                : '#557BF6'.hexColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            items[index].followed == true ? '已关注' : '关注',
                            style: TextStyle(
                              color: items[index].followed == true ? '#333333'.hexColor : '#557BF6'.hexColor,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                itemCount: items.length,
                separatorBuilder: (_, __) => SizedBox(height: 16.w),
              )
            : const NoDataView(),
      ),
    );
  }
}
