import 'package:get/get.dart';
import 'package:holdem/services/message_service.dart';

import '../../../model/message_notice_model.dart';


class MessageNoticeDetailController extends GetxController {

  RxBool isSystem = true.obs;
  var detailData = MessageNoticeModel().obs;

  @override
  void onInit() {
    super.onInit();
    isSystem.value = Get.arguments['pageType'] == 0 ? true : false;
    detailData.value = MessageNoticeModel.fromJson(Get.arguments['data']);
    _requestData();

  }

  void _requestData() async {
    int id = Get.arguments['id'];
    final resData = await MessageService.noticeRead({'notifiesId': id});
    detailData.value = resData;
  }
}
