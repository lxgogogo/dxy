import 'package:event_bus/event_bus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:holdem/services/message_service.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../model/message_notice_model.dart';
import '../../../utils/event_bus_util.dart';

class MessageNoticeController extends GetxController {

  late final RefreshController refreshController;
  int pageNum = 1;
  int pageSize = 20;

  RxBool isSystem = true.obs;
  RxList<MessageNoticeModel> dataList = <MessageNoticeModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    refreshController = RefreshController(initialRefresh: false);
    isSystem.value = Get.arguments['pageType'] == 0 ? true : false;
    _requestData();
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }

  void _requestData() async {
    int type = isSystem.value ? 1 : 2;
    final params = {
      'pageNum': pageNum,
      'pageSize': pageSize,
      'filters': {
        'type': [type]
      }
    };
    final data = await MessageService.noticeList(params);
    if (pageNum == 1) {
      dataList.value = data;
      refreshController.refreshCompleted();
      if (data.length < pageSize) {
        refreshController.loadNoData();
      }
    } else {
      dataList.addAll(data);
      refreshController.loadComplete();
      if (data.length < pageSize) {
        refreshController.loadNoData();
      }
    }
    dataList.refresh();
  }

  void onRefresh() {
    pageNum = 1;
    _requestData();
  }

  void onLoading() {
    pageNum++;
    _requestData();
  }

  void delete(MessageNoticeModel model) async {
    EasyLoading.show(status: '加载中......');
    await MessageService.noticeDelete({'notifiesId': model.id});
    EasyLoading.dismiss();
    dataList.remove(model);
    dataList.refresh();
    EventBusUtil.of.fire(EventRefreshNotice());
  }
}
