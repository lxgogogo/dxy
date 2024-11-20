import 'package:dynamic_tabbar/dynamic_tabbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/route_manager.dart';
import 'package:holdem/model/article.dart';
import 'package:holdem/page/index/page_book_detail.dart';
import 'package:holdem/page/index/home_child_view.dart';
import 'package:holdem/page/index/page_search.dart';
import 'package:holdem/page/index/page_video_list.dart';
import 'package:holdem/utils/constants.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/view/background_container.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
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
            children: [
              Row(
                children: [
                  Expanded(
                    child: TabBar(
                      controller: tabController,
                      tabs: tabs.map((e) => Tab(text: e)).toList(),
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      labelPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                      indicatorPadding: EdgeInsets.only(bottom: 4.px),
                      indicator: UnderlineTabIndicator(
                        borderSide: BorderSide(
                          color: const Color(0xff6198f7),
                          width: 2.px, // 选中线条宽度
                        ),
                        insets: EdgeInsets.symmetric(horizontal: 8.w),
                        borderRadius: BorderRadius.circular(2.px),
                      ),
                      //底部下标颜色
                      enableFeedback: false,
                      overlayColor: WidgetStateProperty.resolveWith<Color>((_) {
                        return Colors.transparent;
                      }),
                      dividerHeight: 0,
                      labelStyle: TextStyle(
                        color: const Color(0xff2c2c2c),
                        fontSize: 16.px,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: TextStyle(
                        color: const Color(0xff666666),
                        fontSize: 16.px,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Image.asset(
                      'assets/images/navi_search.png',
                      width: 16.px,
                      height: 16.px,
                    ),
                    onPressed: () {
                      // 登录按钮点击事件
                      Get.to(const SearchPage());
                    },
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(
                    tabs.length,
                    (index) => HomeChildView(type: types[index]),
                  ),
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
