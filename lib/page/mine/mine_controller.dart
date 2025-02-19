part of 'mine_screen.dart';

class MineController extends GetxController with GetSingleTickerProviderStateMixin {
  final List<String> tabs = ['帖子', '收藏', '评论'];
  late final TabController tabController;

  UserProfile? userProfile;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: tabs.length, vsync: this);
    getUserInfo();
    EventBusManager.eventBus.on().listen((event) {
      if (event.toString() == EventBusAction.refreshPersonalProfile.eventBusTypeName) {
        getUserInfo();
      }
    });
  }

  void getUserInfo() {
    LoginHelper().getUserInfo((data) {
      userProfile = data;
      safeUpdate();
    });
  }
}
