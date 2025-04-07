import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../model/collect_page_model.dart';
import '../../../utils/net_request.dart';

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
    if (index == 3) {
      isDeleting.value = true;
      collectList.refresh();
    }
  }
}
