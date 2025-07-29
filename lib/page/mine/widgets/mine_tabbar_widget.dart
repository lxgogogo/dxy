import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:holdem/widget/custom_underline_tab_indicator.dart';



class StableTabBar extends StatefulWidget {
  final TabController tabController;
  final Function onTap;
  const StableTabBar({super.key, required this.tabController, required this.onTap});

  @override
  State<StatefulWidget> createState() {
    return _StableTabBarState();
  }
}


class _StableTabBarState extends State<StableTabBar> {

  final List<String> tabs = ['帖子', '收藏', '评论'];
  final double selectedFontSize = 18.sp;
  final double unselectedFontSize = 16.sp;
  final Color selectedColor = const Color(0xff333333);
  final Color unselectedColor = const Color(0xff999999);
  int selectIndex = 0;

  @override
  Widget build(BuildContext context) {
    return TabBar(
        controller: widget.tabController,
        isScrollable: false,
        splashFactory: NoSplash.splashFactory, // 禁用点击水波纹
        dividerHeight: 0,
        indicator: RoundUnderlineTabIndicator(
            borderSide: BorderSide(width: 2.w, color: const Color(0xff4260FF)),
            wantToWith: 12.w,
            insets: EdgeInsets.only(bottom: 3.w)), // 自定义静态指示器
        labelPadding: EdgeInsets.zero, // 移除默认内边距
        enableFeedback: false,
        overlayColor:
        WidgetStateProperty.resolveWith<Color>((_) {
          return Colors.transparent;
        }),
        tabs: [
          _buildTab(tabs[0], 0),
          _buildTab(tabs[1], 1),
          _buildTab(tabs[2], 2),
        ],
        onTap: (int index) {
          selectIndex = index;
          if (mounted) {
            setState(() {});
          }
          widget.onTap(index);
        });
  }

  Widget _buildTab(String text, int index) {
    bool isSelected = selectIndex == index ? true : false;
    return SizedBox(
      width: MediaQuery.of(context).size.width / 3, // 等宽分屏
      child: Tab(
        child: AnimatedDefaultTextStyle(
          duration: Duration.zero, // 禁用文字动画
          style: TextStyle(
            fontSize: isSelected ? selectedFontSize : unselectedFontSize,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? selectedColor : unselectedColor,
          ),
          child: Text(text),
        ),
      ),
    );
  }
}