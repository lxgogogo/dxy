import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/model/article.dart';
import 'package:holdem/page/search/widgets/search_child_view.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/storage.dart';
import 'package:holdem/utils/toast_utils.dart';
import 'package:holdem/widget/background_container.dart';
import 'package:holdem/widget/dialog_confirm.dart';
import 'package:holdem/widget/keepalive_wrapper.dart';

part 'search_controller.dart';

enum SearchType {
  news('资讯', categoryAlias: 'news'),
  video('视频', categoryAlias: 'video'),
  book('书籍', categoryAlias: 'book'),
  course('教程', categoryAlias: 'course'),
  user('用户', categoryAlias: ''),
  tag('话题', categoryAlias: ''),
  competition('赛事', categoryAlias: 'competition');

  final String title;

  final String categoryAlias;

  const SearchType(this.title, {required this.categoryAlias});
}

class SearchScreen extends GetView<SearchController> {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
      child: GetBuilder<SearchController>(
          init: SearchController(),
          builder: (controller) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                automaticallyImplyLeading: false,
                titleSpacing: 0.0,
                leading: UnconstrainedBox(
                  child: GestureDetector(
                    onTap: Get.back,
                    child: Padding(
                      padding: EdgeInsets.only(left: 8.w, right: 4.w),
                      child: Image.asset(
                        'assets/images/navi_back.png',
                        width: 24.w,
                      ),
                    ),
                  ),
                ),
                title: buildSearchInput(),
                actions: [
                  GestureDetector(
                    onTap: controller.onSearch,
                    child: Padding(
                      padding: EdgeInsets.only(left: 12.w, right: 16.w),
                      child: Text(
                        '搜索',
                        style: TextStyle(
                          color: const Color(0xff249CFC),
                          fontSize: 15.w,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              backgroundColor: Colors.transparent,
              body: controller.showResult
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 6.w),
                          child: TabBar(
                            controller: controller.tabController,
                            tabs: SearchType.values
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
                              insets: EdgeInsets.symmetric(horizontal: 8.w),
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
                            children: SearchType.values.map((e) => SearchChildView(type: e).keepAlive).toList(),
                          ),
                        )
                      ],
                    )
                  : buildSearchHistory(context),
            );
          }),
    );
  }

  Widget buildSearchInput() {
    return Container(
      height: 32.w,
      padding: EdgeInsets.only(left: 16.w, right: 6.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.w),
        boxShadow: const [
          BoxShadow(
            color: Color(0x80BFD2E2),
            offset: Offset(0, 5),
            blurRadius: 10,
          ),
        ],
        image: const DecorationImage(
          image: AssetImage('assets/images/input_bg.png'),
          fit: BoxFit.contain,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.controller,
              keyboardType: TextInputType.text,
              autocorrect: false,
              onChanged: controller.onChanged,
              cursorHeight: 14.w,
              style: TextStyle(
                fontSize: 14.w,
                color: const Color(0xff333333),
              ),
              decoration: InputDecoration(
                counterText: "",
                hintText: '请输入搜索内容',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(bottom: 12),
                hintStyle: TextStyle(
                  color: const Color(0xFFBBBBBB),
                  fontSize: 14.w,
                ),
              ),
            ),
          ),
          if (controller.controller.text.isNotEmpty)
            GestureDetector(
              onTap: controller.onClear,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Image.asset(
                  'assets/images/clear.png',
                  width: 20.w,
                  height: 20.w,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildSearchHistory(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 200.w),
      margin: EdgeInsets.symmetric(horizontal: 9.w).copyWith(top: 8.w, bottom: 8.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.5.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF5F8FF),
            Color(0xFFECF3FF),
          ],
        ),
        border: Border.all(
          color: const Color.fromRGBO(255, 255, 255, 0.7),
          width: 0.6,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFD6E2F0),
            offset: Offset(0, 3),
            blurRadius: 10,
          ),
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '搜索历史',
                style: TextStyle(
                  color: const Color(0xff95A3C4),
                  fontSize: 12.w,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final isConfirm = await showDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (context) => const DialogConfirm(
                      title: '确定要删除全部历史吗？',
                    ),
                  );
                  if (isConfirm == true) {
                    controller.deleteAllHistory();
                  }
                },
                child: Image.asset(
                  'assets/images/label_del.png',
                  width: 12.w,
                  height: 12.w,
                  color: const Color(0xff95A3C4),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.w),
          Flexible(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8.w,
                runSpacing: 8.w,
                alignment: WrapAlignment.start,
                children: [
                  ...List.generate(
                    controller.historyItems.length,
                    (index) {
                      return GestureDetector(
                        onTap: () {
                          controller.controller.text = controller.historyItems[index];
                          controller.onSearch();
                        },
                        onLongPress: () async {
                          final isConfirm = await showDialog(
                            barrierDismissible: true,
                            context: context,
                            builder: (context) => const DialogConfirm(
                              title: '确认删除当前搜索记录？',
                            ),
                          );
                          if (isConfirm == true) {
                            controller.deleteItemHistory(index);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.w),
                          decoration: BoxDecoration(
                            color: const Color(0xffF8FCFF),
                            borderRadius: BorderRadius.circular(13.5.w),
                          ),
                          child: Text(
                            controller.historyItems[index],
                            style: TextStyle(
                              color: const Color(0xff7282A0),
                              fontSize: 14.w,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
