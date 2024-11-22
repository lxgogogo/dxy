import 'package:dynamic_tabbar/dynamic_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/model/article.dart';
import 'package:holdem/page/index/search_child_view.dart';
import 'package:holdem/page/mine/dialog_confirm.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/eventbus/EventBusAction.dart';
import 'package:holdem/utils/eventbus/EventBusManager.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/utils/storage.dart';
import 'package:holdem/view/background_container.dart';
import 'package:holdem/view/forum/ToastUtils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

enum SearchType {
  news('资讯', categoryAlias: 'news'),
  video('视频', categoryAlias: 'video'),
  book('书籍', categoryAlias: 'book'),
  course('教程', categoryAlias: 'course'),
  user('用户', categoryAlias: ''),
  competition('赛事', categoryAlias: 'competition');

  final String title;

  final String categoryAlias;

  const SearchType(this.title, {required this.categoryAlias});
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  List<TabData> parentTabs = [];
  List<GlobalKey> tabKeys = [];

  final TextEditingController controller = TextEditingController();
  List<String> historyItems = [];
  List<ArticleBean> articles = [];
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: SearchType.values.length, vsync: this);
    historyItems = StorageUtil().prefs!.getStringList('search') ?? [];
    parentTabs = List.generate(SearchType.values.length, (index) {
      final type = SearchType.values[index];
      return TabData(
        index: index,
        title: Tab(text: type.title),
        content: SearchChildView(type: type, controller: controller),
      );
    }).toList();
    super.initState();
  }

  bool showResult = false;

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          titleSpacing: 0.0,
          leading: UnconstrainedBox(
            child: GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Padding(
                padding: EdgeInsets.only(left: 8.px, right: 4.px),
                child: Image.asset(
                  'assets/images/navi_back.png',
                  width: 24.px,
                ),
              ),
            ),
          ),
          title: buildSearchInput(),
          actions: [
            GestureDetector(
              onTap: _onSearch,
              child: Padding(
                padding: EdgeInsets.only(left: 12.px, right: 16.px),
                child: Text(
                  '搜索',
                  style: TextStyle(
                    color: const Color(0xff249CFC),
                    fontSize: 15.px,
                  ),
                ),
              ),
            )
          ],
        ),
        backgroundColor: Colors.transparent,
        body: showResult
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TabBar(
                    controller: _tabController,
                    tabs: SearchType.values
                        .map((e) => Tab(
                              text: e.title,
                            ))
                        .toList(),
                    isScrollable: false,
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
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: SearchType.values
                          .map((e) => SearchChildView(
                                type: e,
                                controller: controller,
                              ))
                          .toList(),
                    ),
                  )
                ],
              )
            : buildSearchHistory(context),
      ),
    );
  }

  Widget buildSearchInput() {
    return Container(
      height: 32.px,
      padding: EdgeInsets.only(left: 15.px, right: 12.px),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.px),
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
              controller: controller,
              keyboardType: TextInputType.text,
              autocorrect: false,
              onChanged: (value) {
                if (mounted) {
                  setState(() {});
                }
              },
              cursorHeight: 14.px,
              style: TextStyle(height: 1, fontSize: 14.px, color: Color(0xff333333)),
              // inputFormatters: [
              //   LengthLimitingTextInputFormatter(10),
              // ],
              decoration: InputDecoration(
                // isDense: true,
                // prefixIcon: Icon(Icons.search),
                counterText: "",
                hintText: '请输入搜索内容',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(bottom: 12),
                hintStyle: TextStyle(
                  color: const Color(0xFFBBBBBB),
                  fontSize: 14.px,
                ),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
                controller.clear();
                showResult = false;
                if (mounted) {
                  setState(() {});
                }
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.px),
                child: Image.asset(
                  'assets/images/clear.png',
                  width: 20.px,
                  height: 20.px,
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
                  fontSize: 12.px,
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
                    StorageUtil().prefs?.remove('search');
                    historyItems.clear();
                    setState(() {});
                  }
                },
                child: Image.asset(
                  'assets/images/label_del.png',
                  width: 12.px,
                  height: 12.px,
                  color: const Color(0xff95A3C4),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.px),
          Flexible(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8.px,
                runSpacing: 8.px,
                alignment: WrapAlignment.start,
                children: [
                  ...List.generate(historyItems.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        controller.text = historyItems[index];
                        _onSearch();
                      },
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('删除'),
                              content: const SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    Text('确认删除当前搜索记录?'),
                                    // Text('你可以在这里添加更多的内容.')
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('取消'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('确认'),
                                  onPressed: () {
                                    // 在这里添加确认操作的代码
                                    setState(() {
                                      historyItems.removeAt(index);
                                      StorageUtil().prefs!.setStringList('search', historyItems);
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.px, vertical: 4.px),
                        decoration: BoxDecoration(
                          color: const Color(0xffF8FCFF),
                          borderRadius: BorderRadius.circular(13.5.px),
                        ),
                        child: Text(
                          historyItems[index],
                          style: TextStyle(
                            color: const Color(0xff7282A0),
                            fontSize: 14.px,
                          ),
                        ),
                      ),
                    );
                  })
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _onSearch() {
    String keyword = controller.text;
    if (keyword.isEmpty) {
      ToastUtils.showToast("请输入搜索内容");
      return;
    }
    if (!historyItems.contains(keyword)) {
      historyItems.insert(0, keyword);
    }
    StorageUtil().prefs?.setStringList('search', historyItems);

    showResult = true;
    setState(() {});

    EventBusUtil.of.fire(EventRefreshSearchResult());
  }
}
