
import '../model/res_base_model.dart';
import '../utils/api.dart';
import '../utils/http_utils.dart';

class CollectService {

  // 收藏列表
  static Future categoryList(data) async {
    final res = await HttpUtils.postNew(Api.categoryList, params: data);
    return res ?? ResBaseModel.defaultRes;
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