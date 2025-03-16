import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/page/message/widgets/message_child_view.dart';
import 'package:holdem/utils/constants.dart';
import 'package:holdem/utils/log_util.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/background_container.dart';
import 'package:holdem/widget/keepalive_wrapper.dart';

import '../../widget/custom_underline_tab_indicator.dart';
import '../../widget/dynamic_tabbar.dart';

part 'message_controller.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final List<String> tabs = ['@我的', '评论我的', '点赞我的', '收藏我的'];
  final List<String> types = ['at', 'comment', 'like', 'favorite'];

  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: tabs.length,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: '#F7F8FC'.hexColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 4.w),
              child: TabBar(
                controller: tabController,
                tabs: tabs
                    .map((e) => Tab(
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Text(e),
                              Visibility(
                                visible: false,
                                child: Positioned(
                                    right: -4.w,
                                    top: -4.w,
                                    child: Container(
                                      width: 8.w,
                                      height: 8.w,
                                      decoration: const ShapeDecoration(
                                        color: Color(0xFFFF3232),
                                        shape: OvalBorder(),
                                      ),
                                    )),
                              )
                            ],
                          ),
                          // child: Text(myTabs[i].text.toString()),
                        ))
                    .toList(),
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
                labelStyle: TextStyle(
                  color: const Color(0xff2c2c2c),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: TextStyle(
                  color: const Color(0xff666666),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: types.map((e) => MessageChildView(type: e).keepAlive).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
