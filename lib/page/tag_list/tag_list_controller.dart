part of 'tag_list_screen.dart';

class TagListController extends GetxController with RefreshControllerMixin {
  late TextEditingController searchController;
  late FocusNode searchFocusNode;
  List<TagModel> hotItems = [];
  List<TagModel> items = [];
  List<TagModel> selectedItems = [];

  late final RefreshController searchRefreshController;
  bool showSearchResult = false;

  int searchPageNum = 1;
  bool searchNoMore = false;

  @override
  void onInit() {
    searchRefreshController = RefreshController();
    searchController = TextEditingController();
    searchFocusNode = FocusNode()
      // ..requestFocus()
      ..addListener(() {
        safeUpdate();
      });

    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    onRefresh();
    intTagList();
  }
  void intTagList(){
    final selectTags = Get.find<FeedPostController>().tagList;
    if(selectTags.isNotEmpty){
      selectedItems.addAll(selectTags);
      safeUpdate();
    }
  }
  void addSelectTag(TagModel tag) {
    if (selectedItems.length >= 10) {
      showToast('最多只能选择10个标签');
      return;
    }
    if (selectedItems.any((e) => e.id == tag.id)) {
      ToastUtils.showToast('不可重复插入同一话题');
      return;
    }
    selectedItems.add(tag);
    safeUpdate();
  }
  void removeTag(int index) {
    selectedItems.removeAt(index);
    safeUpdate();
  }
  @override
  Future<List?> loadData() async {
    if (page == 1) hotItems.clear();
    final res = await CommonService.of.tagIndex(
      pageNum: page,
      pageSize: pageSize,
    );
    if (res.isSuccess) {
      final listRes = res.data['list'] as List? ?? [];
      final records = listRes.map((e) => TagModel.fromJson(e as Map? ?? {})).toList();
      hotItems.addAll(records);
      return records;
    }
    return null;
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
    searchPageNum = 1;
    try {
      final res = await CommonService.of.tagIndex(
        pageNum: searchPageNum,
        pageSize: pageSize,
        keyword: searchController.text,
        isShowLoading: true,
      );
      items.clear();
      if (res.isSuccess) {
        final listRes = res.data['list'] as List? ?? [];
        final records = listRes.map((e) => TagModel.fromJson(e as Map? ?? {})).toList();
        items.addAll(records);
      }
      searchRefreshController.refreshCompleted();
      if (items.length < pageSize) {
        searchNoMore = true;
        searchRefreshController.loadNoData();
      } else {
        searchNoMore = false;
        searchRefreshController.resetNoData();
      }
    } catch (e) {
      searchRefreshController.refreshFailed();
    } finally {
      safeUpdate();
    }
  }

  Future<void> onSearchLoading() async {
    if (searchNoMore) {
      searchRefreshController.loadNoData();
      return;
    }
    searchPageNum++;
    try {
      final res = await CommonService.of.tagIndex(
        pageNum: searchPageNum,
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
        searchNoMore = true;
        searchRefreshController.loadNoData();
      } else {
        searchNoMore = false;
        searchRefreshController.loadComplete();
      }
    } catch (e) {
      searchRefreshController.loadFailed();
    } finally {
      safeUpdate();
    }
  }
}
