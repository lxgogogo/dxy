import 'package:dynamic_tabbar/dynamic_tabbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  final List<String> tabs = ['资讯', '视频', '书籍', '教程'];
  final List<String> types = ['news', 'video', 'book', 'course'];
  List<TabData> parentTabs = [];

  List<ArticleBean> articles = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < tabs.length; i++) {
      parentTabs.add(TabData(
        index: i,
        title: Tab(text: tabs[i]),
        content: HomeChildView(type: types[i]),
      ));
    }
  }

  void getVideos() {
    NetRequest().indexList({
      'pageNum': 1,
      'pageSize': 10,
      'filters': {
        'categoryAlias': 'video' //'article'
      }
    }, (data) {
      List<ArticleBean> dataList = List<ArticleBean>.from(data['list'].map((article) => ArticleBean.fromJson(article)));
      setState(() {
        articles = dataList;
      });
    });
  }

  void getArticles() {
    NetRequest().indexList({
      'pageNum': 1,
      'pageSize': 10,
      'filters': {
        'categoryAlias': 'book' //'article'
      }
    }, (data) {
      List<ArticleBean> dataList = List<ArticleBean>.from(data['list'].map((article) => ArticleBean.fromJson(article)));
      setState(() {
        articles = dataList;
      });
    });
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
          child: DynamicTabBarWidget(
            dynamicTabs: parentTabs,
            isScrollable: false,
            showBackIcon: false,
            showNextIcon: false,
            labelPadding: EdgeInsets.fromLTRB(6.px, 0, 6.px, 0),
            indicatorPadding: EdgeInsets.only(bottom: 4.px),
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                color: const Color(0xff6198f7),
                width: 2.px, // 选中线条宽度
              ),
              insets: EdgeInsets.symmetric(horizontal: 8.px),
              borderRadius: BorderRadius.circular(2.px),
            ),
            trailing: SizedBox(
              width: 120.px,
              child: Row(
                children: [
                  const Spacer(),
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
            onTabChanged: (index) {},
            onTabControllerUpdated: (TabController) {},
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
