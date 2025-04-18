
import '../model/home_hot_tag_model.dart';
import '../model/res_base_model.dart';
import '../utils/api.dart';
import '../utils/http_utils.dart';

class HomeService {

  static Future<List<HomeHotTagModel>> queryTopHeatTag(data) async {
    final res = await HttpUtils.postNew(Api.topHeatTag ,params: data);
    List<HomeHotTagModel> saveData = [];
    if ((res ?? ResBaseModel.defaultRes).isSuccess) {
      final data = (res?.data ?? {})['list'];
      int index = -1;
      for (final map in data) {
        index++;
        HomeHotTagModel model = HomeHotTagModel.fromJson(map);
        if (index == 0) {
          model.select = true;
        }
        saveData.add(model);
      }
    }
    return saveData;
  }
}