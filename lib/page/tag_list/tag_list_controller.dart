part of 'tag_list_screen.dart';

class TagListController extends GetxController {
  late TextEditingController searchController;
  late FocusNode searchFocusNode;
  List<TagModel> hotItems = [];
  List<TagModel> items = [];

  late final RefreshController searchRefreshController;
  bool showSearchResult = false;

  int pageNum = 1;
  int pageSize = 20;
  bool noMore = false;

  @override
  void onInit() {
    searchRefreshController = RefreshController();
    searchController = TextEditingController();
    searchFocusNode = FocusNode()
      ..requestFocus()
      ..addListener(() {
        safeUpdate();
      });
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    getTagList();
  }

  Future<void> getTagList() async {
    final res = await CommonService.of.tagIndex(pageNum: 1, pageSize: pageSize);
    if (res.isSuccess) {
      final listRes = res.data['list'] as List? ?? [];
      final records = listRes.map((e) => TagModel.fromJson(e as Map? ?? {})).toList();
      hotItems.assignAll(records);
      safeUpdate();
    }
  }
}

extension SearchFunc on TagListController {
  void onClear() {
    searchController.clear();
    showSearchResult = false;
    safeUpdate();
  }

  void onChanged(String value) {
    DebounceThrottle.debounce(() {
      if (searchController.text.trim().isEmpty) {
        showSearchResult = false;
        safeUpdate();
        return;
      }
      if (!showSearchResult) {
        showSearchResult = true;
        safeUpdate();
      }
      onSearch();
    });
  }

  Future<void> onSearch() async {
    EasyLoading.show(status: 'loading...');
    pageNum = 1;
    try {
      final res = await CommonService.of.tagIndex(
        pageNum: pageNum,
        pageSize: pageSize,
        keyword: searchController.text,
      );
      items.clear();
      if (res.isSuccess) {
        final listRes = res.data['list'] as List? ?? [];
        final records = listRes.map((e) => TagModel.fromJson(e as Map? ?? {})).toList();
        items.addAll(records);
      }
      searchRefreshController.refreshCompleted();
      if (items.length < pageSize) {
        noMore = true;
        searchRefreshController.loadNoData();
      } else {
        noMore = false;
        searchRefreshController.resetNoData();
      }
    } catch (e) {
      searchRefreshController.refreshFailed();
    } finally {
      safeUpdate();
      EasyLoading.dismiss();
    }
  }

  Future<void> onSearchLoading() async {
    if (noMore) {
      searchRefreshController.loadNoData();
      return;
    }
    pageNum++;
    try {
      final res = await CommonService.of.tagIndex(
        pageNum: pageNum,
        pageSize: pageSize,
        keyword: searchController.text,
      );
      int recordsSize = 0;
      if (res.isSuccess) {
        final listRes = res.data['list'] as List? ?? [];
        final records = listRes.map((e) => TagModel.fromJson(e as Map? ?? {})).toList();
        recordsSize = records.length;
        items.addAll(records);
      } else {}
      if (recordsSize < pageSize) {
        noMore = true;
        searchRefreshController.loadNoData();
      } else {
        noMore = false;
        searchRefreshController.loadComplete();
      }
    } catch (e) {
      searchRefreshController.loadFailed();
    } finally {
      safeUpdate();
    }
  }
}
