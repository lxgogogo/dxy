
import '../model/collect_group_model.dart';
import '../model/res_base_model.dart';
import '../utils/api.dart';
import '../utils/http_utils.dart';

class CollectService {

  // 收藏列表
  static Future<List<CollectGroupModel>> categoryList() async {
    final res = await HttpUtils.postNew(Api.categoryList);
    List<CollectGroupModel> saveList = [];
    if (res?.isSuccess ?? false) {
      final data = res?.data;
      for (final map in data) {
        CollectGroupModel model = CollectGroupModel.fromJson(map);
        saveList.add(model);
      }
    }
    return saveList;
  }

  // 保存收藏
  static Future saveCategoryCollect(data) async {
    final res = await HttpUtils.postNew(Api.categorySave, params: data);
    return res ?? ResBaseModel.defaultRes;
  }

  // 删除收藏内容
  static Future deleteFavorite(data) async {
    final res = await HttpUtils.postNew(Api.deleteFavorite, params: data);
    return res ?? ResBaseModel.defaultRes;
  }

  // 删除收藏分类
  static Future deleteCategory(data) async {
    final res = await HttpUtils.postNew(Api.deleteCategory, params: data);
    return res ?? ResBaseModel.defaultRes;
  }
}