part of 'mine_screen.dart';

class MineController extends GetxController with GetSingleTickerProviderStateMixin {
  final List<String> tabs = ['帖子', '收藏', '评论'];
  late final TabController tabController;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: tabs.length, vsync: this);
    UserStore.of.getUserInfo();
  }
}
