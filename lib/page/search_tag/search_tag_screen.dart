import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/num_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/model/tag_model.dart';
import 'package:holdem/page/search_tag/widgets/search_tag_child_view.dart';
import 'package:holdem/widget/background_container.dart';
import 'package:holdem/widget/common_app_bar.dart';
import 'package:holdem/widget/count_widget.dart';
import 'package:holdem/widget/keepalive_wrapper.dart';

part 'search_tag_controller.dart';

enum SearchTagType {
  // news('资讯', categoryAlias: 'news'),
  video('视频', categoryAlias: 'video'),
  book('书籍', categoryAlias: 'book'),
  course('教程', categoryAlias: 'course'),
  feed('论坛', categoryAlias: 'thread');

  final String title;

  final String categoryAlias;

  const SearchTagType(this.title, {required this.categoryAlias});
}

class SearchTagScreen extends GetView<SearchTagController> {
  const SearchTagScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SearchTagController>(
      global: false,
      init: SearchTagController(),
      builder: (controller) {
        return Scaffold(
          appBar: CommonAppBar.arrowBack(
            context,
          ),
          backgroundColor: '#f7f8fc'.hexColor,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 16.w, right: 16.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        controller.tagModel?.name ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                            color: '#333333'.hexColor),
                      ),
                    ),

                    Text(
                      '阅读',
                      style: TextStyle(
                        color: Color(0xFF333333).withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      controller.tagModel?.viewCount?.abbreviateNumber ?? '0',
                      style: const TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 12,
                        fontFamily: 'PingFang SC',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      '讨论',
                      style: TextStyle(
                        color: Color(0xFF333333).withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      controller.tagModel?.commentCount?.abbreviateNumber ??
                          '0',
                      style: const TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 12,
                        fontFamily: 'PingFang SC',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 24.w,
              ),
              Padding(
                padding: EdgeInsets.only(left: 6.w),
                child: TabBar(
                  controller: controller.tabController,
                  tabs: SearchTagType.values
                      .map((e) => Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6.w),
                            child: Tab(text: e.title),
                          ))
                      .toList(),
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelPadding: EdgeInsets.fromLTRB(6.w, 0, 6.w, 0),
                  indicatorPadding: EdgeInsets.only(bottom: 4.w),
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(
                      color: const Color(0xff6198f7),
                      width: 2.w, // 选中线条宽度
                    ),
                    insets: EdgeInsets.symmetric(horizontal: 15.w),
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                  enableFeedback: false,
                  overlayColor: WidgetStateProperty.resolveWith<Color>((_) {
                    return Colors.transparent;
                  }),
                  dividerHeight: 0,
                  labelStyle: TextStyle(
                    color: const Color(0xff2c2c2c),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: TextStyle(
                    color: const Color(0xff666666),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: controller.tabController,
                  children: SearchTagType.values
                      .map((e) => SearchTagChildView(
                            type: e,
                            tagModel: controller.tagModel,
                          ).keepAlive)
                      .toList(),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
