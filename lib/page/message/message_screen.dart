import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/page/message/widgets/message_child_view.dart';
import 'package:holdem/services/message_service.dart';
import 'package:holdem/widget/keepalive_wrapper.dart';

import '../../gen/assets.gen.dart';
import '../../routes/app_pages.dart';
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

class _MessagePageState extends State<MessagePage>
    with AutomaticKeepAliveClientMixin {
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
            return FocusDetector(
                onFocusGained: controller.onFocusGained,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildNoticeBtnWidget(controller),
                        Obx(() {
                          return GestureDetector(
                            onTap: controller.messageReadAll,
                            child: Opacity(
                              opacity: controller.unReadCount > 0 ? 1 : 0.3,
                              child: Padding(
                                padding: EdgeInsets.only(right: 16.w, top: 16.w),
                                child: Image.asset(
                                  'assets/images/message_clean.png',
                                  width: 24.w,
                                  height: 24.w,
                                )
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.zero,
                      child: Obx(() {
                        return TabBar(
                          controller: controller.tabController,
                          tabs: MessageType.values.map((e) {
                            final unReadCount = switch (e) {
                              MessageType.at =>
                              UserStore.of.badgeModel.value?.at,
                              MessageType.comment =>
                              UserStore.of.badgeModel.value?.comment,
                              MessageType.like =>
                              UserStore.of.badgeModel.value?.like,
                              MessageType.favorite =>
                              UserStore.of.badgeModel.value?.favorite,
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
                            borderSide: BorderSide(
                                width: 2.w,
                                color: const Color(0xff4260FF)),
                            wantToWith: 12.w,
                            insets: EdgeInsets.symmetric(vertical: 8.w),
                          ),
                          enableFeedback: false,
                          overlayColor:
                          WidgetStateProperty.resolveWith<Color>((_) {
                            return Colors.transparent;
                          }),
                          dividerHeight: 0,
                          labelPadding: EdgeInsets.symmetric(horizontal: 20.w),
                          labelStyle: TextStyle(
                            color: const Color(0xff2c2c2c),
                            fontSize: 16.sp,
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
                    Expanded(
                      child: TabBarView(
                        controller: controller.tabController,
                        children:
                            List.generate(MessageType.values.length, (index) {
                          final messageType = MessageType.values[index];
                          return GetBuilder<MessageChildController>(
                            init: MessageChildController(messageType),
                            tag: messageType.type,
                            builder: (childController) =>
                                MessageChildView(controller: childController)
                                    .keepAlive,
                          );
                        }),
                      ),
                    ),
                  ],
                ));
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Widget _buildNoticeBtnWidget(controller) {
    return Obx(() => Padding(
          padding: EdgeInsets.only(left: 16.w),
          child: Row(
            children: [
              _buildButtonItemWidget(0, controller.notifiesOfficial.value,
                  onTap: () {
                Get.toNamed(Routes.noticeList, arguments: {'pageType': 0});
              }),
              SizedBox(width: 20.w),
              _buildButtonItemWidget(1, controller.notifiesPrivate.value,
                  onTap: () {
                Get.toNamed(Routes.noticeList, arguments: {'pageType': 1});
              })
            ],
          )
        ));
  }

  Widget _buildButtonItemWidget(int index, int badge, {Function? onTap}) {
    String count = badge > 99 ? '99+' : '$badge';
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap();
        }
      },
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          SizedBox(width: 58.w, height: 78.w),
          Column(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                color: Colors.transparent,
                child: Image.asset(
                  index == 0
                      ? Assets.images.iconNoticeSystemN.path
                      : Assets.images.iconNoticeUserN.path,
                  width: 48.w,
                  height: 48.w,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 5.w),
              Text(
                index == 0 ? '官方通知' : '用户私信',
                style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.black
                ),
              )
            ],
          ),
          if (badge > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 22.w,
                height: 22.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.all(Radius.circular(11.w))),
                child: Text(
                  count,
                  style: TextStyle(fontSize: 8.sp, color: Colors.white),
                ),
              ),
            )
        ],
      )
    );
  }
}
