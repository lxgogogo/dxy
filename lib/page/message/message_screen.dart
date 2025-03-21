import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/page/main/main_screen.dart';
import 'package:holdem/page/message/widgets/message_child_view.dart';
import 'package:holdem/widget/keepalive_wrapper.dart';

import '../../gen/assets.gen.dart';
import '../../widget/custom_underline_tab_indicator.dart';

part 'message_controller.dart';

enum MessageType {
  at('@我的', type: 'at'),
  comment('评论我的', type: 'comment'),
  like('点赞我的', type: 'like'),
  favorite('收藏我的', type: 'favorite');

  final String title;

  final String type;

  const MessageType(this.title, {required this.type});
}

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: '#F7F8FC'.hexColor,
      body: SafeArea(
        bottom: false,
        child: GetBuilder<MessageController>(
          init: MessageController(),
          builder: (controller) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 4.w),
                        child: Obx(() {
                          return TabBar(
                            controller: controller.tabController,
                            tabs: MessageType.values.map((e) {
                              return Tab(
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Text(e.title),
                                    if ((controller.unReadCount ?? 0) > 0)
                                      Positioned(
                                        right: -4.w,
                                        top: -4.w,
                                        child: Container(
                                          width: 8.w,
                                          height: 8.w,
                                          decoration: const ShapeDecoration(
                                            color: Color(0xFFFF3232),
                                            shape: OvalBorder(),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
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
                          );
                        }),
                      ),
                    ),
                    GestureDetector(
                      onTap: controller.messageReadAll,
                      child: Padding(
                        padding: EdgeInsets.only(right: 16.w),
                        child: SvgPicture.asset(
                          Assets.svg.messageClean,
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: controller.tabController,
                    children: List.generate(controller.childControllers.length, (index) {
                      return GetBuilder<MessageChildController>(
                        init: controller.childControllers[index],
                        global: false,
                        builder: (childController) => MessageChildView(controller: childController).keepAlive,
                      );
                    }),
                  ),
                ),
                SizedBox(
                  height: kBottomNavigationBarHeight + ScreenUtil().bottomBarHeight,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
