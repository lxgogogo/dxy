import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

mixin RefreshControllerMixin<R> on GetxController {
  late final RefreshController refreshController;

  RxBool isLoadingObs = true.obs;

  bool get isLoading => isLoadingObs.value;

  int page = 1;

  int get pageSize => 20;

  bool noMore = false;

  Future<void> onRefresh() async {
    if (refreshController.isLoading) {
      refreshController.refreshCompleted();
      return;
    }
    page = 1;
    try {
      final res = await loadData();
      refreshController.refreshCompleted();
      final recordsSize = res?.length ?? 0;
      if (recordsSize < pageSize) {
        noMore = true;
        refreshController.loadNoData();
      } else {
        noMore = false;
        refreshController.resetNoData();
      }
      isLoadingObs.value = false;
      safeUpdate();
    } catch (e) {
      isLoadingObs.value = false;
      debugPrint('onLoading: $e');
      // DialogUtil.showToast(e.toString());
      refreshController.refreshFailed();
      safeUpdate();
    }
  }

  Future<void> onLoading() async {
    if (refreshController.isRefresh) {
      refreshController.loadComplete();
      return;
    }
    if (noMore) {
      refreshController.loadNoData();
      return;
    }
    page++;
    try {
      final res = await loadData();
      final recordsSize = res?.length ?? 0;

      if (recordsSize < pageSize) {
        noMore = true;
        refreshController.loadNoData();
      } else {
        noMore = false;
        refreshController.loadComplete();
      }
      safeUpdate();
    } catch (e) {
      debugPrint('onLoading: $e');
      refreshController.loadFailed();
      safeUpdate();
    }
  }

  Future<List<R>?> loadData();

  @override
  void onInit() {
    refreshController = RefreshController();
    super.onInit();
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }
}
