import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/model/course_model.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:holdem/utils/event_bus_util.dart';

import '../../../../widget/common_image.dart';

class CourseDetailAllItem extends StatefulWidget {
  final CourseModel item;
  final VoidCallback? onTap;

  const CourseDetailAllItem({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  State<StatefulWidget> createState() {
    return _CourseDetailAllItemState();
  }
}

class _CourseDetailAllItemState extends State<CourseDetailAllItem> {

  bool _isLogin = false;
  StreamSubscription? _eventSubscription;

  void _onFocusGained() {
    _isLogin = UserStore.of.isLogin;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _isLogin = UserStore.of.isLogin;
    _eventSubscription = EventBusUtil.of.on<EventRefreshPractise>().listen((event) {
      widget.item.practiseCompleted = event.completed;
      if (widget.item.knowledgeCompleted == widget.item.knowledgeTotal &&
          widget.item.practiseCompleted == widget.item.practiseTotal &&
          widget.item.challengeCompleted == widget.item.challengeTotal) {
        // 已完成
      }else {
        // 进行中
        widget.item.status = 1;
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusDetector(
      onFocusGained: _onFocusGained,
      child: GestureDetector(
        onTap: () {
          if (widget.item.status == 0) {
            widget.onTap?.call();
          }
        },
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: '#58A5FF'.hexColor.withOpacity(0.1),
                blurRadius: 8.63.r,
                offset: Offset(0, 4.32.w),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.item.des ?? '',
                style: TextStyle(
                  color: '#333333'.hexColor,
                  fontSize: 14.sp,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (_isLogin)...[
                SizedBox(height: 12.w),
                Row(
                  children: [
                    CommonImage.net(
                      imageUrl: widget.item.icon ?? '',
                      width: 20.w,
                      height: 20.w,
                    ),
                    SizedBox(width: 12.w),
                    if ((widget.item.knowledgeTotal ?? 0) > 0)
                      Expanded(
                        child: CourseTypeItem(
                          assetName: Assets.svg.iconKnowledge,
                          count: widget.item.knowledgeCompleted ?? 0,
                          total: widget.item.knowledgeTotal ?? 0,
                          status: widget.item.status,
                        ),
                      ),
                    if ((widget.item.practiseTotal ?? 0) > 0)
                      Expanded(
                        child: CourseTypeItem(
                          assetName: Assets.svg.iconPractice,
                          count: widget.item.practiseCompleted ?? 0,
                          total: widget.item.practiseTotal ?? 0,
                          status: widget.item.status,
                        ),
                      ),
                    if ((widget.item.challengeTotal ?? 0) > 0)
                      Expanded(
                        child: CourseTypeItem(
                          assetName: Assets.svg.iconChallenge,
                          count: widget.item.challengeCompleted ?? 0,
                          total: widget.item.challengeTotal ?? 0,
                          status: widget.item.status,
                        ),
                      ),
                    CourseStatusBtn(
                      status: widget.item.status,
                      onTap: widget.onTap,
                    ),
                  ],
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class CourseTypeItem extends StatelessWidget {
  const CourseTypeItem({
    super.key,
    required this.assetName,
    required this.count,
    required this.total,
    required this.status,
  });

  final String assetName;
  final num count;
  final num total;

  //0 未开始   1进行中  2已完成
  final int? status;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      child: Row(
        children: [
          SvgPicture.asset(
            assetName,
            width: 16.w,
            height: 16.w,
          ),
          SizedBox(width: 4.w),
          Text.rich(
            TextSpan(
              text: status == 1 ? '$count/' : '',
              children: [
                TextSpan(
                  text: '$total',
                  style: TextStyle(
                    color: AppTheme.color_666666,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
            style: TextStyle(
              color: AppTheme.color_666666,
              fontSize: 12.sp,
            ),
          )
        ],
      ),
    );
  }
}

class CourseStatusBtn extends StatelessWidget {
  //0 未开始   1进行中  2已完成
  final int? status;
  final VoidCallback? onTap;

  const CourseStatusBtn({
    super.key,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String title = '';
    Color bgColor = Colors.transparent;
    Color textColor = Colors.transparent;
    if (status == 0) {
      title = '点击开始';
      bgColor = '#557BF6'.hexColor;
      textColor = Colors.white;
    } else if (status == 1) {
      title = '进行中';
      bgColor = '#557BF6'.hexColor.withOpacity(0.1);
      textColor = '#557BF6'.hexColor;
    } else if (status == 2) {
      title = '已完成';
      bgColor = '#333333'.hexColor.withOpacity(0.1);
      textColor = '#999999'.hexColor;
    }
    return GestureDetector(
      onTap: () {
        if (status == 0) {
          onTap?.call();
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
        // 设置内边距
        child: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
