part of 'search_tag_screen.dart';

class SearchTagController extends GetxController with GetSingleTickerProviderStateMixin {
  static SearchTagController get of => Get.find<SearchTagController>();

  late TabController tabController;

  @override
  void onInit() {
    tabController = TabController(
      length: SearchTagType.values.length,
      vsync: this,
    );
    super.onInit();
  }
}
