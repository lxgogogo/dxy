import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../model/article.dart';
import '../../utils/net_request.dart';
import '../home/home_screen.dart';

/**
 * Created on 2025/3/6
 * Description:
 */
class BookListController extends GetxController{
  final RefreshController refreshController = RefreshController(initialRefresh: false);
  final pageController = PageController(viewportFraction: 1, keepPage: true);
  List<ArticleBean> articles = [];
  int pageNum = 1;
  int pageSize = 20;
  bool noMore = false;
  bool isLoaded = false;
  bool isShowHomeMenu = false;
  final ScrollController scrollController = ScrollController();
  List<ArticleBean> bookItems = [];
  @override
  void onReady() {
    super.onReady();
    reqListData();
    loadBooks();
    scrollController.addListener(() {
      final isShow = scrollController.offset > (211.w - 12.w);
      if (isShowHomeMenu != isShow) {
        isShowHomeMenu = isShow;
        safeUpdate();
      }
    });
  }
  Future<void> loadBooks() async {
    await NetRequest().bookRecommend({"pageSize": 4}, showLoading: false, (data) {
      final items = List<ArticleBean>.from(
        data.map((article) => ArticleBean.fromJson(article)),
      );
      if (items.isNotEmpty) {
        bookItems = items;
        safeUpdate();
      }
    });
  }
  Future<void> reqListData({bool showLoading = false}) async {

    Map<String, Object> params = {
      'pageNum': pageNum,
      'pageSize': pageSize,
      'filters': {
        'categoryAlias': HomeType.book.categoryAlias,
      }
    };
    try {
      int recordsSize = 0;
      await NetRequest().indexList(params, showLoading: false,(data) {
        final dataList = List<ArticleBean>.from(data['list'].map((article) => ArticleBean.fromJson(article)));
        recordsSize = dataList.length;
        if (pageNum == 1) {
          articles.clear();
        }
        articles.addAll(dataList);
      });
      if (recordsSize < pageSize) {
        noMore = true;
        refreshController.loadNoData();
      } else {
        noMore = false;
        refreshController.loadComplete();
      }
    } catch (e) {
      refreshController.loadFailed();
    } finally {
      isLoaded = true;
      safeUpdate();
    }
  }
  void onLoading() async {
    if (noMore) {
      refreshController.loadNoData();
      return;
    }
    pageNum++;
    reqListData();
  }
}