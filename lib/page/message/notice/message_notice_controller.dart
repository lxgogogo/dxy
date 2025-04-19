import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Message_noticeController extends GetxController {

  final RefreshController refreshController =
  RefreshController(initialRefresh: false);

  bool isSystem = true;

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
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
