import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SpecialClassicFooter extends StatelessWidget {
  const SpecialClassicFooter({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final navBarDistance = kBottomNavigationBarHeight + ScreenUtil().bottomBarHeight;
    return ClassicFooter(
      height: 60 + navBarDistance,
      noDataText: '—— 已经到底啦 ——',
      outerBuilder: (child) {
        return Container(
          height: 60 + navBarDistance,
          padding: EdgeInsets.only(bottom: navBarDistance),
          alignment: Alignment.center,
          child: child,
        );
      },
    );
  }
}
