import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:super_tooltip/super_tooltip.dart';

import '../stores/user_store.dart';

class FeedMoreAction extends StatefulWidget {
  final VoidCallback? onShield;
  final VoidCallback? onShieldUser;
  final VoidCallback? onReport;

  const FeedMoreAction({
    super.key,
    this.onShield,
    this.onShieldUser,
    this.onReport,
  });

  @override
  State<FeedMoreAction> createState() => _FeedMoreActionState();
}

class _FeedMoreActionState extends State<FeedMoreAction> {
  final SuperTooltipController _tipController = SuperTooltipController();
  List<String> actions = [
    '屏蔽该内容',
    '屏蔽该用户',
    '举报该内容',
  ];

  @override
  Widget build(BuildContext context) {
    return SuperTooltip(
      showBarrier: true,
      controller: _tipController,
      popupDirection: TooltipDirection.down,
      backgroundColor: Colors.transparent,
      hasShadow: false,
      borderColor: Colors.transparent,
      arrowLength: 0,
      arrowTipDistance: 10.w,
      bubbleDimensions: EdgeInsets.zero,
      touchThroughAreaShape: ClipAreaShape.rectangle,
      touchThroughAreaCornerRadius: 10,
      minimumOutsideMargin: 0,
      barrierColor: Colors.transparent,
      right: 16.w,
      content: Container(
        width: 84.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10.r,
              offset: Offset(0, 5.w),
            ),
            BoxShadow(
              color: const Color(0xfffafcff),
              blurRadius: 1.r,
              spreadRadius: -1.r,
              offset: Offset(0, -1.w),
            ),
          ],
        ),
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: actions.length,
          padding: EdgeInsets.zero,
          itemBuilder: (BuildContext context, int index) {
            final item = actions[index];
            return GestureDetector(
              onTap: () {
                _tipController.hideTooltip();
                switch (index) {
                  case 0:
                    widget.onShield?.call();
                  case 1:
                    widget.onShieldUser?.call();
                  case 2:
                    widget.onReport?.call();
                }
              },
              child: Container(
                height: 41.5.w,
                alignment: Alignment.center,
                child: Text(
                  item,
                  style: TextStyle(
                    color:'#333333'.hexColor,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (_, __) => Container(
            margin: EdgeInsets.symmetric(horizontal: 12.w),
            color: '#333333'.hexColor.withOpacity(0.1),
            height: 1,
          ),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          UserStore.of.checkLogin(() {
            _tipController.showTooltip();
          });
        },
        behavior: HitTestBehavior.translucent,
        child: Container(
          width: 20.w,
          height: 20.w,
          alignment: Alignment.center,
          child: Icon(
            Icons.more_vert,
            size: 14.sp,
          ),
        ),

      ),
    );
  }
}
