import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/widget/custom_underline_tab_indicator.dart';

class CommonTabBar extends StatefulWidget {
  final List<String> tabs;
  final TabController? controller;

  const CommonTabBar({
    super.key,
    required this.tabs,
    this.controller,
  });

  @override
  State<StatefulWidget> createState() => _CommonTabBarState();
}

class _CommonTabBarState extends State<CommonTabBar> {
  int selectIndex = 0;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: widget.controller,
      tabs: List.generate(widget.tabs.length, (index) {
        return _buildTab(
          widget.tabs[index],
          index,
        );
      }),
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      indicator: RoundUnderlineTabIndicator(
        borderSide: BorderSide(width: 2.w, color: const Color(0xff4260FF)),
        wantToWith: 12.w,
      ),
      enableFeedback: false,
      overlayColor: WidgetStateProperty.resolveWith<Color>((_) {
        return Colors.transparent;
      }),
      dividerHeight: 0,
      onTap: (int index) {
        selectIndex = index;
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  Widget _buildTab(
    String text,
    int index,
  ) {
    return Tab(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            text,
            style: selectIndex == index
                ? TextStyle(
                    color: '#333333'.hexColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  )
                : TextStyle(
                    color: '#333333'.hexColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
          ),
          Opacity(
            opacity: 0,
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
