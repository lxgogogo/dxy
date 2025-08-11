part of 'mine_screen.dart';

class MineController extends GetxController with GetSingleTickerProviderStateMixin {
  final List<String> tabs = ['帖子', '收藏', '评论'];
  late final TabController tabController;
  RxString dxyBalance = '0.00'.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: tabs.length, vsync: this);
  }

  void onFocusGained() async {
    if (UserStore.of.isLogin) {
      _requestData();
      await UserStore.of.getUserInfo();
      safeUpdate();
    }
  }

  void _requestData() async {
    final data =  await PointsService.coinBalance();
    if (data != null) {
      dxyBalance.value = '${data['dxyBalance'] ?? 0.00}';
    }
  }
}
