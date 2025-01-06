part of 'search_tag_screen.dart';

class SearchTagController extends GetxController with GetSingleTickerProviderStateMixin {
  static SearchTagController get of => Get.find<SearchTagController>();

  late TabController tabController;

  TagModel? tagModel;

  @override
  void onInit() {
    tagModel = Get.arguments?['tag'] as TagModel?;
    tabController = TabController(
      length: SearchTagType.values.length,
      vsync: this,
    );
    super.onInit();
  }
}
