import 'package:holdem/utils/dialog_util.dart';

import '../model/res_base_model.dart';
import '../utils/http_utils.dart';

class PointsService {
  static Future coinBalance() async {
    final res = await HttpUtils.postNew('/api/user/coinBalance');
    if (res?.isSuccess ?? false) {
      final data = res?.data;
      return data;
    } else {
      DialogUtil.showToast('${res?.msg}');
      return null;
    }
  }

  static Future coinTrans(data) async {
    final res = await HttpUtils.postNew('/api/user/coinTrans',
        params: data, showLoading: true);
    return res ?? ResBaseModel.defaultRes;
  }

  static Future coinAutoTransStatus(data) async {
    final res = await HttpUtils.postNew('/api/user/coinAutoTransStatus',
        params: data, showLoading: true);
    return res ?? ResBaseModel.defaultRes;
  }
}
