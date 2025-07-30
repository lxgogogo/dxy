import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/model/user.dart';
import 'package:holdem/model/userdata_list.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/widget/common_app_bar.dart';
import 'package:holdem/widget/no_data.dart';
import 'package:holdem/widget/scroll_to_top_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../stores/user_store.dart';
import '../../utils/app_theme.dart';
import '../../utils/dialog_util.dart';
import '../../utils/track_utils.dart';

part 'following_controller.dart';

class FollowingScreen extends StatefulWidget {
  final bool isFollowPage;

  const FollowingScreen({super.key, required this.isFollowPage});

  @override
  createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  int pageNum = 1;
  int pageSize = 20;

  List<UserProfile> items = [];
  bool _isMounted = false;

  bool noMore = false;
  final RefreshController _refreshController = RefreshController();

  final ScrollController scrollController = ScrollController();

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
    reqListData();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  reqListData() async {
    int recordsSize = 0;
    try {
      if (widget.isFollowPage) {
        await NetRequest()
            .followedList(pageNum.toString(), pageSize.toString(), '', (data) {
          UserDataList dataList = UserDataList.fromJson(data);
          recordsSize = dataList.list?.length ?? 0;
          if (_isMounted) {
            if (pageNum == 1) {
              items = dataList.list!;
            } else {
              items.addAll(dataList.list!);
            }
          }
        });
      } else {
        await NetRequest().fansList(pageNum.toString(), pageSize.toString(), '',
            (data) {
          UserDataList dataList = UserDataList.fromJson(data);
          recordsSize = dataList.list?.length ?? 0;
          if (_isMounted) {
            setState(() {
              if (pageNum == 1) {
                items = dataList.list!;
              } else {
                items.addAll(dataList.list!);
              }
            });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar.arrowBack(
        context,
        title: widget.isFollowPage ? '我的关注' : '我的粉丝',
        onBack: () {
          UserStore.of.getUserInfo();
          Get.back();
        }
      ),
      backgroundColor: Colors.white,
      body: SmartRefresher(
        scrollController: scrollController,
        enablePullDown: true,
        enablePullUp: items.isNotEmpty == true || !noMore,
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: items.isNotEmpty
            ? ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.w).copyWith(top: 5.w),
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      ClipOval(
                        child: CachedNetworkImage(
                          width: 36.w,
                          height: 36.w,
                          fit: BoxFit.cover,
                          imageUrl: items[index].avatar ?? '',
                          errorWidget: (context, url, error) =>
                              Image.asset('assets/images/default_avatar.png'),
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
                            ),
                          ),
                        ),
                      ),
                      _buildFollowBtnWidget(index)
                    ],
                  );
                },
                itemCount: items.length,
                separatorBuilder: (_, __) => SizedBox(height: 16.w),
              )
            : const Center(child: NoDataView()),
      ).scrollToTopWrapper(
        scrollController,
      ),
    );
  }

  Widget _buildFollowBtnWidget(int index) {
    String title = '';
    bool followed = items[index].followed ?? false;
    bool isfans = items[index].isfans ?? false;
    Color bgColor = AppTheme.color_333333.withOpacity(0.1);
    Color titleColor = AppTheme.color_333333;
    if (widget.isFollowPage) {
      if (isfans) {
        title = '互相关注';
        if (!followed) {
          title = '回关';
        }
      } else {
        if (followed) {
          title = '已关注';
          titleColor = AppTheme.color_999999;
        } else {
          title = '+关注';
          titleColor = AppTheme.color_557BF6;
          bgColor = AppTheme.color_557BF6.withOpacity(0.1);
        }
      }
    } else {
      title = '回关';
      if (followed) {
        title = '互相关注';
      }
    }
    return GestureDetector(
      onTap: () {
        if (widget.isFollowPage) {
          NetRequest().followerToggle(
            items[index].id!,
            false,
            (data) {
              if (items[index].followed ?? false) {
                DialogUtil.showToast('取消关注成功');
                TrackUtils.trackEvent(userLogType: '113009');
              } else {
                DialogUtil.showToast('关注成功');
                TrackUtils.trackEvent(userLogType: '113010');
              }
              items[index].followed = !items[index].followed!;
              if (_isMounted) {
                setState(() {});
              }
            },
          );
        } else {
          NetRequest().followerToggle(
            items[index].id!,
            !items[index].followed!,
            (data) {
              if (items[index].followed ?? false) {
                DialogUtil.showToast('取消关注成功');
                TrackUtils.trackEvent(userLogType: '113009');
              } else {
                DialogUtil.showToast('关注成功');
                TrackUtils.trackEvent(userLogType: '113010');
              }
              items[index].followed = !items[index].followed!;
              if (_isMounted) {
                setState(() {});
              }
            },
          );
        }
      },
      child: Container(
        width: 72.w,
        height: 28.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: titleColor,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
