import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../model/article.dart';
import '../../utils/net_request.dart';
import '../home/home_screen.dart';

class BookListController extends GetxController with GetSingleTickerProviderStateMixin {
  final RefreshController refreshController = RefreshController();
  List<ArticleBean> articles = [];
  int pageNum = 1;
  int pageSize = 20;
  bool noMore = false;
  bool isLoaded = false;
  bool isShowHomeMenu = false;
  final ScrollController scrollController = ScrollController();
  List<ArticleBean> bookItems = [];

  bool isSwitching = false;
  late AnimationController animationController;

  @override
  void onInit() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    super.onInit();
  }

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

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }

  Future<void> loadBooks() async {
    if (isSwitching) return;
    isSwitching = true;
    safeUpdate();
    animationController.repeat();
    await NetRequest().bookRecommend({
      "pageSize": 4,
      "filters": {
        "ids": bookItems.map((e) => e.id).toList(),
      },
    }, showLoading: false, (data) {
      final items = List<ArticleBean>.from(
        data.map((article) => ArticleBean.fromJson(article)),
      );
      if (items.isNotEmpty) {
        bookItems = items;
        safeUpdate();
      }
    }).whenComplete(() {
      isSwitching = false;
      safeUpdate();
      animationController.stop();
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
      await NetRequest().indexList(params, showLoading: false, (data) {
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
