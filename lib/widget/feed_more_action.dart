import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:super_tooltip/super_tooltip.dart';

import '../stores/user_store.dart';
import 'common_operations_sheet.dart';

typedef FeedMoreActions = Map<String, VoidCallback?>;

class FeedMoreAction extends StatefulWidget {
  final FeedMoreActions actions;

  const FeedMoreAction({super.key, required this.actions});

  @override
  State<FeedMoreAction> createState() => _FeedMoreActionState();
}

class _FeedMoreActionState extends State<FeedMoreAction> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        UserStore.of.checkLogin(() {
          final actions = widget.actions.keys.toList();
          showCommonOperationsSheet(
            items: actions,
            itemBuilder: (int index, bool hasSelected) {
              return Text(
                actions[index],
                style: TextStyle(
                  fontSize: 16.sp,
                  color: '#333333'.hexColor,
                ),
                textAlign: TextAlign.center,
              );
            },
            onSelectItem: (int index) {
              widget.actions[actions[index]]?.call();
            },
          );
        });
      },
      behavior: HitTestBehavior.translucent,
      child: SvgPicture.asset(
        Assets.svg.iconMoreVert,
        width: 24.w,
        height: 24.w,
      ),
    );
  }
}
