import 'dart:async';

import 'package:flutter/material.dart';
import 'package:holdem/utils/dialog_util.dart';
import 'package:get/get.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../model/collect_page_model.dart';
import '../../../services/collect_service.dart';
import '../../../utils/event_bus_util.dart';
import '../../../utils/net_request.dart';
import '../../../utils/dialog_util.dart';
import '../../../utils/track_utils.dart';
import '../../../widget/dialog_common.dart';

class CollectListController extends GetxController {
  final RefreshController refreshController =
      RefreshController(initialRefresh: false);

  RxList<CollectModel> collectList = <CollectModel>[].obs;
  RxInt selectAllCount = 0.obs;
  List<dynamic> selectIds = [];
  int pageNum = 1;
  int pageSize = 20;
  bool noMore = false;
  final ScrollController scrollController = ScrollController();

  RxBool loaded = false.obs;
  RxBool enable = false.obs;
  // 是否删除中
  RxBool isDeleting = false.obs;
  RxBool isSelectAll = false.obs;
  RxString name = ''.obs;
  int id = 0;

  StreamSubscription? eventSub;

  @override
  void onReady() {
    id = Get.arguments['id'] ?? 0;
    name.value = Get.arguments['name'] ?? '';
    _addEvent();
    _reqListData();
    super.onReady();
  }

  @override
  void onClose() {
    eventSub?.cancel();
    super.onClose();
  }

  // TODO: Private Method

  void _addEvent() {
    eventSub = EventBusUtil.of.on<EventRefreshName>().listen((event) {
      name.value = event.name;
      _reqListData();
    });
  }

  void _reqListData({bool showLoading = true}) async {
    int recordsSize = 0;
    try {
      await NetRequest().userFavoriteList(pageNum, pageSize, '',
          showLoading: showLoading, categoryId: id, (data) {
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
      if (collectList.isEmpty) {
        isDeleting.value = false;
      }
    }
  }

  void _deleteCollect() async {
    DialogUtil.showLoading();
    final res = await CollectService.deleteCategory({'id': id});
    DialogUtil.dismiss();
    if (res.isSuccess) {
      EventBusUtil.of.fire(EventRefreshName(''));
      DialogUtil.showToast('删除成功');
      Get.back();
    } else {
      DialogUtil.showToast(res.msg);
    }
  }

  void _deleteCollectList({String tips = '移出成功'}) async {
    DialogUtil.showLoading();
    final res = await CollectService.saveCategoryCollect({
      'id': id,
      'deleteIdList': selectIds
    });
    selectIds.clear();
    selectAllCount.value = 0;
    DialogUtil.dismiss();
    if (res.isSuccess) {
      _reqListData();
      EventBusUtil.of.fire(EventRefreshName(name.value));
      DialogUtil.showToast(tips);
    } else {
      DialogUtil.showToast(res.msg);
    }
  }

  void _getSelectIds() {
    int selectCount = 0;
    selectIds.clear();
    for (int i = 0; i < collectList.length; i++) {
      final model = collectList[i];
      if (model.select ?? false) {
        selectCount++;
        selectIds.add('${model.id ?? 0}');
      }
    }
    selectAllCount.value = selectIds.length;
    if (collectList.length == selectCount) {
      isSelectAll.value = true;
    } else {
      isSelectAll.value = false;
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
    collectList[index].select = !(collectList[index].select ?? false);
    _getSelectIds();
    collectList.refresh();
    enable.value = selectIds.isEmpty ? false : true;
  }

  void selectAlertOnTap(int index) {
    if (index == 0) {
      Get.toNamed(Routes.finishCreateCollect,
              arguments: {'name': name.value, 'create': false, 'id': id});
    } else if (index == 1) {
      if (collectList.isNotEmpty) {
        isDeleting.value = true;
        collectList.refresh();
      } else {
        DialogUtil.showToast('当前没有可以选择的内容');
      }
    } else if (index == 2) {
      Get.toNamed(Routes.createCollect,
          arguments: {'create': false, 'id': id, 'title': name.value});
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
                  _deleteCollect();
                },
                cancelText: '取消',
              ));
    }
  }

  void selectAllOnTap() {
    isSelectAll.value = !isSelectAll.value;
    for (final model in collectList) {
      model.select = isSelectAll.value;
    }
    _getSelectIds();
    collectList.refresh();
  }

  void deleteCollectList() {
    if (selectIds.isEmpty) {
      DialogUtil.showToast('请先选择要移出的内容');
      return;
    }
    _deleteCollectList();
  }

  // 移除分类
  void deleteItem(int index) async {
    final model = collectList[index];
    NetRequest().favoriteDelete(
        model.id, (data) {
      DialogUtil.showToast('删除成功');
      selectIds.clear();
      selectAllCount.value = 0;
      collectList.removeAt(index);
      EventBusUtil.of.fire(EventRefreshCollect(model.relId ?? 0));
      TrackUtils.trackEvent(userLogType: '113007');
    });
  }
}
