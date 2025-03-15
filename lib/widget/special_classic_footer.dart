import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SpecialClassicFooter extends StatelessWidget {
  const SpecialClassicFooter({
    super.key,
    this.title
  });
  final String? title;



  @override
  Widget build(BuildContext context) {
    final navBarDistance = kBottomNavigationBarHeight + ScreenUtil().bottomBarHeight;
    return ClassicFooter(
      height: 60 + navBarDistance,
      noDataText: title??'没有更多内容',
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
