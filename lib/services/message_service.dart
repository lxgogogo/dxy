
import 'package:holdem/model/message_notice_model.dart';

import '../model/res_base_model.dart';
import '../utils/api.dart';
import '../utils/http_utils.dart';

class MessageService {

  static Future noticeRead(data) async {
    final res = await HttpUtils.postNew(Api.noticeRead,params: data);
    final resData = res ?? ResBaseModel.defaultRes;
    if (resData.isSuccess) {
      return MessageNoticeModel.fromJson(resData.data);
    }
    return MessageNoticeModel();
  }

  static Future noticeList(data) async {
    final res = await HttpUtils.postNew(Api.noticeList, params: data);
    final resData = res ?? ResBaseModel.defaultRes;
    List<MessageNoticeModel> saveData = [];
    if (resData.isSuccess) {
      for (final map in resData.data['list']) {
        final model = MessageNoticeModel.fromJson(map);
        if (model.isDel != 1) {
          saveData.add(model);
        }
      }
    }
    return saveData;
  }

  static Future noticeDelete(data) async {
    final res = await HttpUtils.postNew(Api.noticeDelete, params: data);
    return res ?? ResBaseModel.defaultRes;
  }

  static Future noticeBadge() async {
    final res = await HttpUtils.getNew(Api.noticeBadge);
    final data = res ?? ResBaseModel.defaultRes;;
    if (data.isSuccess) {
      return data.data;
    }
    return {};
  }

}