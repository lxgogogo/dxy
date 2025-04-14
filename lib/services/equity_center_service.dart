
import '../model/res_base_model.dart';
import '../utils/api.dart';
import '../utils/http_utils.dart';

class EquityCenterService {


  static Future userEquity() async {
    final res = await HttpUtils.postNew(Api.userEquity);
    return res ?? ResBaseModel.defaultRes;
  }
}