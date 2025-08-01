import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'custom_underline_tab_indicator.dart';

class CommonTabbarWidget extends StatefulWidget {
  final List<String> tabs;
  final double selectedFontSize;
  final double unselectedFontSize;
  final Color selectedColor;
  final Color unselectedColor;
  final TabController tabController;
  final Function onTap;
  const CommonTabbarWidget(
      {super.key,
      required this.tabs,
      required this.tabController,
      required this.onTap,
      this.selectedFontSize = 18,
      this.unselectedFontSize = 16,
      this.selectedColor = const Color(0xff333333),
      this.unselectedColor = const Color(0xff999999)});

  @override
  State<StatefulWidget> createState() {
    return _CommonTabbarWidgetState();
  }
}

class _CommonTabbarWidgetState extends State<CommonTabbarWidget> {
  int selectIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int index = -1;
    return TabBar(
        controller: widget.tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        splashFactory: NoSplash.splashFactory, // 禁用点击水波纹
        dividerHeight: 0,
        indicator: RoundUnderlineTabIndicator(
          borderSide: BorderSide(
              width: 2.w, color: const Color(0xff4260FF)),
          wantToWith: 12.w,
        ),// 自定义静态指示器
        labelPadding: EdgeInsets.zero, // 移除默认内边距
        enableFeedback: false,
        overlayColor: WidgetStateProperty.resolveWith<Color>((_) {
          return Colors.transparent;
        }),
        tabs: [
          ...widget.tabs.map((e) {
            index++;
            return _buildTab(e, index);
          })
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
    double width = MediaQuery.of(context).size.width / widget.tabs.length;
    return SizedBox(
      width: width,
      child: Tab(
        child: AnimatedDefaultTextStyle(
          duration: Duration.zero, // 禁用文字动画
          style: TextStyle(
            fontSize: isSelected
                ? widget.selectedFontSize
                : widget.unselectedFontSize,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? widget.selectedColor : widget.unselectedColor,
          ),
          child: Text(text),
        ),
      ),
    );
  }
}
