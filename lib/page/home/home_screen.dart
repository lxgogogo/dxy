import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/model/article.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/widget/background_container.dart';
import 'package:holdem/widget/keepalive_wrapper.dart';

import 'widgets/home_child_view.dart';

part 'home_controller.dart';

enum HomeType {
  news('资讯', categoryAlias: 'news'),
  video('视频', categoryAlias: 'video'),
  book('书籍', categoryAlias: 'book'),
  course('教程', categoryAlias: 'course');

  final String title;

  final String categoryAlias;

  const HomeType(this.title, {required this.categoryAlias});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final List<String> tabs = ['资讯', '视频', '书籍', '教程'];
  late final TabController tabController;

  final List<String> types = ['news', 'video', 'book', 'course'];

  List<ArticleBean> articles = [];

  @override
  void initState() {
    tabController = TabController(length: tabs.length, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BackgroundContainer(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 6.w),
                child: Row(
                  children: [
                    Expanded(
                      child: TabBar(
                        controller: tabController,
                        tabs: HomeType.values
                            .map((e) => Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6.w),
                          child: Tab(text: e.title),
                        ))
                            .toList(),
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        labelPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                        indicatorPadding: EdgeInsets.only(bottom: 4.w),
                        indicator: UnderlineTabIndicator(
                          borderSide: BorderSide(
                            color: const Color(0xff6198f7),
                            width: 2.w,
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
                          fontSize: 16.w,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: TextStyle(
                          color: const Color(0xff666666),
                          fontSize: 16.w,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Image.asset(
                        'assets/images/navi_search.png',
                        width: 16.w,
                        height: 16.w,
                      ),
                      onPressed: () {
                        Get.toNamed(Routes.search);
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: HomeType.values.map((e) => HomeChildView(type: e).keepAlive).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
