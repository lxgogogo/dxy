part of 'course_screen.dart';

class CourseController extends GetxController {
  final ScrollController scrollController = ScrollController();

  bool isShowHomeMenu = false;

  List<IndexCategory> categories = [];
  int categorySel = 0;
  int? categoryId;
  List<CourseBean> courses = [];

  int pageNum = 1;
  bool noMore = false;
  final RefreshController refreshController = RefreshController();
  final ScrollController listController = ScrollController();

  @override
  void onReady() {
    loadCourseTabs();
    loadCourses();
    super.onReady();
    scrollController.addListener(() {
      final isShow = scrollController.offset > (211.w - 12.w);
      if (isShowHomeMenu != isShow) {
        isShowHomeMenu = isShow;
        safeUpdate();
      }
    });
  }

  Future<void> loadCourseTabs() async {
    await NetRequest().courseCategory({"parentAlias": "course", "parentId": 1}, showLoading: false, (data) {
      List<IndexCategory> categoryList =
          List<IndexCategory>.from(data.map((category) => IndexCategory.fromJson(category)));
      categoryList.insert(0, IndexCategory(name: '全部'));
      categories = categoryList;
      safeUpdate();
    });
  }

  Future<void> loadCourses() async {
    Map<String, Object> params = {
      'pageNum': pageNum,
      'pageSize': 20,
      'filters': {
        'categoryAlias': 'course',
        if (categoryId != null) 'categoryId': categoryId,
      }
    };
    try {
      int recordsSize = 0;
      await NetRequest().courseList(params, showLoading: false, (data) {
        List<CourseBean> dataList = List<CourseBean>.from(data['list'].map((course) => CourseBean.fromJson(course)));
        recordsSize = dataList.length;
        if (pageNum == 1) {
          courses.clear();
        }
        courses.addAll(dataList);
      });
      if (pageNum == 1) {
        refreshController.refreshCompleted();
        if (recordsSize < 20) {
          noMore = true;
          refreshController.loadNoData();
        } else {
          noMore = false;
          refreshController.resetNoData();
        }
      } else {
        if (recordsSize < 20) {
          noMore = true;
          refreshController.loadNoData();
        } else {
          noMore = false;
          refreshController.loadComplete();
        }
      }
    } catch (e) {
      if (pageNum == 1) {
        refreshController.refreshFailed();
      } else {
        refreshController.loadFailed();
      }
    } finally {
      safeUpdate();
    }
  }

  Future<void> onRefresh() async {
    pageNum = 1;
    loadCourses();
  }

  Future<void> onLoading() async {
    if (noMore) {
      refreshController.loadNoData();
      return;
    }
    pageNum++;
    loadCourses();
  }

  onTapTab(int index) {
    categorySel = index;
    categoryId = categories[index].id;
    pageNum = 1;
    safeUpdate();
    loadCourses();
    listController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }
}
