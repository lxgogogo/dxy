import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:holdem/services/message_service.dart';
import 'package:holdem/utils/toast_utils.dart';
import 'package:holdem/widget/dialog_common.dart';
import 'package:html/parser.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../model/message_notice_model.dart';
import '../../../utils/event_bus_util.dart';

class MessageNoticeController extends GetxController {

  late final RefreshController refreshController;
  int pageNum = 1;
  int pageSize = 20;

  RxBool isSystem = true.obs;
  RxList<MessageNoticeModel> dataList = <MessageNoticeModel>[].obs;

  // 是否删除中
  RxBool isDeleting = false.obs;
  RxBool isSelectAll = false.obs;
  RxInt selectAllCount = 0.obs;
  List<dynamic> selectIds = [];

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

  void _getSelectIds() {
    int selectCount = 0;
    selectIds.clear();
    for (int i = 0; i < dataList.length; i++) {
      final model = dataList[i];
      if (model.select ?? false) {
        selectCount++;
        selectIds.add('${model.id ?? 0}');
      }
    }
    selectAllCount.value = selectIds.length;
    if (dataList.length == selectCount) {
      isSelectAll.value = true;
    } else {
      isSelectAll.value = false;
    }
  }

  // TODO: Public Method

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
    ToastUtils.showToast('删除成功');
    EasyLoading.dismiss();
    dataList.remove(model);
    dataList.refresh();
    EventBusUtil.of.fire(EventRefreshNotice());
  }

  String htmlToPlainText(String htmlString) {
    final document = parse(htmlString);
    return document.body?.text ?? '';
  }

  void isDeleteOnTap(context) async {
    if (!isDeleting.value) {
      isDeleting.value = !isDeleting.value;
      dataList.refresh();
    } else {
      // 执行删除
      if (selectIds.isEmpty) {
        ToastUtils.showToast('请先选择要删除的消息');
        return;
      }
      await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) =>
          CommonDialog(
            title: '删除信件',
            content:
            '确定删除全部所选消息吗？',
            confirmText: '确认删除',
            onConfirm: () {
              Navigator.of(context).pop();
            },
          ),
      );
    }
  }

  void selectOnTap(int index) {
    dataList[index].select = !(dataList[index].select ?? false);
    _getSelectIds();
    dataList.refresh();
  }

  void selectAllOnTap() {
    isSelectAll.value = !isSelectAll.value;
    for (final model in dataList) {
      model.select = isSelectAll.value;
    }
    _getSelectIds();
    dataList.refresh();
  }
}
