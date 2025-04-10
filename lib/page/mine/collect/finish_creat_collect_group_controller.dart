
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/toast_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../model/collect_page_model.dart';
import '../../../routes/app_pages.dart';
import '../../../services/collect_service.dart';

class FinishCreatCollectGroupController extends GetxController {

  final RefreshController refreshController = RefreshController(initialRefresh: false);

  RxList<CollectModel> collectList = <CollectModel>[].obs;
  List<Map<String, dynamic>> selectIds = [];
  int pageNum = 1;
  int pageSize = 20;
  bool noMore = false;
  RxBool loaded = false.obs;
  String name = '';
  bool create = true;
  int categoryId = 0;

  @override
  void onReady() {
    name = Get.arguments['name'] ?? '';
    create = Get.arguments['create'] ?? true;
    if (Get.arguments['id'] != null) {
      categoryId = Get.arguments['id'] ?? 0;
    }
    _reqListData();
    super.onReady();
  }

  @override
  void onClose() {
    refreshController.dispose();
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
    collectList[index].select = !(collectList[index].select ?? false);
    selectIds.clear();
    for (int i = 0; i < collectList.length; i++) {
      final model = collectList[i];
      if (model.select ?? false) {
        selectIds.add({
          'relId': model.relId,
          'relType': model.relType,
          'status': 1
        });
      }
    }
    collectList.refresh();
  }

  void finishOnTap() async {
    EasyLoading.show(status: '加载中...');
    var map = {
      'name': name,
      'favoriteDtoList': selectIds
    };
    if (!create) {
      map = {
        'id': categoryId,
        'favoriteDtoList': selectIds
      };
    }
    final res = await CollectService.saveCategoryCollect(map);
    EasyLoading.dismiss();
    if (res.isSuccess) {
      ToastUtils.showToast('保存成功');
      if (create) {
        Get.until((route) => route.settings.name == Routes.main);
      } else {
        Get.back();
      }
    } else {
      ToastUtils.showToast(res.msg);
    }
  }
}
