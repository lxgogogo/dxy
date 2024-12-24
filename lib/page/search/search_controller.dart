part of 'search_screen.dart';

class SearchController extends GetxController with GetSingleTickerProviderStateMixin {
  static SearchController get of => Get.find<SearchController>();

  final TextEditingController controller = TextEditingController();
  List<String> historyItems = [];
  List<ArticleBean> articles = [];
  late TabController tabController;
  bool showResult = false;

  @override
  void onInit() {
    tabController = TabController(
      length: SearchType.values.length,
      vsync: this,
    );
    historyItems = StorageUtil().prefs?.getStringList('search') ?? [];
    super.onInit();
  }

  void onChanged(String value) {
    safeUpdate();
  }

  void onClear() {
    FocusManager.instance.primaryFocus?.unfocus();
    controller.clear();
    showResult = false;
    safeUpdate();
  }

  void deleteAllHistory() {
    historyItems.clear();
    StorageUtil().prefs?.remove('search');
    safeUpdate();
  }

  void deleteItemHistory(int index) {
    historyItems.removeAt(index);
    StorageUtil().prefs?.setStringList('search', historyItems);
    safeUpdate();
  }

  void onSearch() {
    String keyword = controller.text;
    if (keyword.isEmpty) {
      ToastUtils.showToast("请输入搜索内容");
      return;
    }
    if (!historyItems.contains(keyword)) {
      historyItems.insert(0, keyword);
      StorageUtil().prefs?.setStringList('search', historyItems);
    }

    showResult = true;
    safeUpdate();

    EventBusUtil.of.fire(EventRefreshSearchResult());
  }
}
