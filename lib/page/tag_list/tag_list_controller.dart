part of 'tag_list_screen.dart';

class TagListController extends GetxController with RefreshControllerMixin {
  List items = [];

  @override
  void onReady() {
    super.onReady();
    onRefresh();
  }

  @override
  Future<List?> loadData() async {
    if (page == 1) items.clear();
    final res = await CommonService.of.tagIndex();
    if (res.isSuccess) {
      final listRes = res.data['list'] as List? ?? [];
      final records = listRes.map((e) => TagModel.fromJson(e as Map<String, dynamic>? ?? {})).toList();
      items.addAll(records);
      return records;
    }
    return null;
  }
}
