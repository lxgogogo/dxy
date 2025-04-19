import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MessageNoticeController extends GetxController {

  late final RefreshController refreshController;

  bool isSystem = true;

  @override
  void onInit() {
    super.onInit();
    refreshController = RefreshController(initialRefresh: false);
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }

  void onRefresh() {

  }

  void onLoading() {

  }
}
