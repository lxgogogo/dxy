part of 'search_screen.dart';

class SearchController extends GetxController with GetSingleTickerProviderStateMixin {
  static SearchController get of => Get.find<SearchController>();

  final TextEditingController controller = TextEditingController();
  List<String> historyItems = [];
  late TabController tabController;
  bool showResult = false;
  List<SearchTop> hotTagItems = [];

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(
      length: SearchType.values.length,
      vsync: this,
    );
  }

  @override
  void onReady() {
    super.onReady();
    loadHistory();
    loadHotTags();
  }

  Future<void> loadHistory() async {
    historyItems = StorageUtil().prefs?.getStringList('search') ?? [];
    safeUpdate();
  }

  Future<void> loadHotTags() async {
    final res = await CommonService.of.tagIndex(
      pageNum: 1,
      pageSize: 20,
    );
    if (res.isSuccess) {
      final listRes = res.data as List;
      final records = listRes.map((e) => SearchTop.fromMap(e )).toList();
      if (records.isNotEmpty) {
        hotTagItems.assignAll(records);
        safeUpdate();
      }
    }
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

  void onSearch(BuildContext context) {
    String keyword = controller.text;
    if (keyword.isEmpty) {
      ToastUtils.showToast("请输入搜索内容");
      return;
    }
    FocusScope.of(context).requestFocus(FocusNode());
    if (historyItems.length < 30) {
      if (historyItems.contains(keyword)) {
        historyItems.remove(keyword);
      }
      historyItems.insert(0, keyword);
    } else {
      if (historyItems.contains(keyword)) {
        historyItems.remove(keyword);
      } else {
        historyItems.removeLast();
      }
      historyItems.insert(0, keyword);
    }

    StorageUtil().prefs?.setStringList('search', historyItems);

    FocusManager.instance.primaryFocus?.unfocus();
    showResult = true;
    safeUpdate();

    EventBusUtil.of.fire(EventRefreshSearchResult());
  }
}
