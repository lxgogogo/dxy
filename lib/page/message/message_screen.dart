import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/page/message/widgets/message_child_view.dart';
import 'package:holdem/widget/keepalive_wrapper.dart';

import '../../gen/assets.gen.dart';
import '../../stores/user_store.dart';
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
                _buildNoticeBtnWidget(),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 4.w),
                        child: Obx(() {
                          return TabBar(
                            controller: controller.tabController,
                            tabs: MessageType.values.map((e) {
                              final unReadCount = switch (e) {
                                MessageType.at => UserStore.of.badgeModel.value?.at,
                                MessageType.comment => UserStore.of.badgeModel.value?.comment,
                                MessageType.like => UserStore.of.badgeModel.value?.like,
                                MessageType.favorite => UserStore.of.badgeModel.value?.favorite,
                              };
                              return Tab(
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Text(e.title),
                                    if ((unReadCount ?? 0) > 0)
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
                    Obx(() {
                      return GestureDetector(
                        onTap: controller.messageReadAll,
                        child: Opacity(
                          opacity: controller.unReadCount > 0 ? 1 : 0.3,
                          child: Padding(
                            padding: EdgeInsets.only(right: 16.w),
                            child: SvgPicture.asset(
                              Assets.svg.messageClean,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: controller.tabController,
                    children: List.generate(MessageType.values.length, (index) {
                      final messageType = MessageType.values[index];
                      return GetBuilder<MessageChildController>(
                        init: MessageChildController(messageType),
                        tag: messageType.type,
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

  Widget _buildNoticeBtnWidget() {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.w, top: 12.w),
      child: Row(
        children: [
          _buildButtonItemWidget(0),
          SizedBox(width: 20.w),
          _buildButtonItemWidget(1)
        ],
      ),
    );
  }

  Widget _buildButtonItemWidget(int index) {
    return GestureDetector(
      onTap: () {},
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          SizedBox(width: 58.w, height: 58.w),
          Container(
            width: 48.w,
            height: 48.w,
            color: Colors.transparent,
            child: Image.asset(
              Assets.images.iconNoticeUserN.path,
              width: 48.w,
              height: 48.w,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 22.w,
              height: 22.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.all(Radius.circular(11.w))
              ),
              child: Text(
                '99+',
                style: TextStyle(
                    fontSize: 8.sp,
                    color: Colors.white
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
