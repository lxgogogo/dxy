import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../model/collect_page_model.dart';
import '../../../utils/net_request.dart';
import '../../../widget/dialog_common.dart';

class CollectListController extends GetxController {

  final RefreshController refreshController = RefreshController(initialRefresh: false);

  RxList<CollectModel> collectList = <CollectModel>[].obs;
  List<int> selectIds = [];
  int pageNum = 1;
  int pageSize = 20;
  bool noMore = false;
  RxBool loaded = false.obs;
  RxBool enable = false.obs;
  // 是否删除中
  RxBool isDeleting = false.obs;
  RxBool isSelectAll = false.obs;

  @override
  void onReady() {
    _reqListData();
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  // TODO: Private Method

  void _reqListData({bool showLoading = true}) async {
    int recordsSize = 0;
    try {
      await NetRequest().userFavoriteList(pageNum, pageSize, '',
          showLoading: showLoading, (data) {
            CollectPageModel dataList = CollectPageModel.fromJson(data);
            recordsSize = (dataList.list ?? []).length;
            if (pageNum == 1) {
              collectList.clear();
            }
            collectList.addAll(dataList.list ?? []);
          });
      if (pageNum == 1) {
        refreshController.refreshCompleted();
        if (recordsSize < pageSize) {
          noMore = true;
          refreshController.loadNoData();
        } else {
          noMore = false;
          refreshController.resetNoData();
        }
      } else {
        if (recordsSize < pageSize) {
          noMore = true;
          refreshController.loadNoData();
        } else {
          noMore = false;
          refreshController.loadComplete();
        }
      }
    } catch (e) {
      refreshController.loadFailed();
    } finally {
      loaded.value = true;
    }
  }

  // TODO: Public Method

  void onRefresh() async {
    pageNum = 1;
    _reqListData(showLoading: false);
  }

  void onLoading() async {
    if (noMore) {
      refreshController.loadNoData();
      return;
    }
    pageNum++;
    _reqListData(showLoading: false);
  }

  void selectOnTap(int index) {
    for (int i = 0; i < collectList.length; i++) {
      final model = collectList[i];
      model.select = false;
    }
    collectList[index].select = true;
    selectIds = [collectList[index].id ?? 0];
    collectList.refresh();
    enable.value = selectIds.isEmpty ? false : true;
  }

  void selectAlertOnTap(int index) {
    if (index == 0) {
      Get.toNamed(Routes.finishCreateCollect);
    } else if (index == 1) {
      isDeleting.value = true;
      collectList.refresh();
    } else if (index == 2) {
      Get.toNamed(Routes.createCollect, arguments: {'create': false});
    } else {
      showDialog(
        barrierDismissible: false,
        context: Get.context!,
        builder: (context) => CommonDialog(
          title: '删除分类',
          content: '确定要删除这个分类吗？',
          confirmText: '确定',
          onConfirm: () {
            Get.close(1);
          },
          cancelText: '取消',
        )
      );
    }
  }

  void selectAllOnTap() {
    isSelectAll.value = !isSelectAll.value;
    for (final model in collectList) {
      model.select = isSelectAll.value;
    }
    collectList.refresh();
  }
}
