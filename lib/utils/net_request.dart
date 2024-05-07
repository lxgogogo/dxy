import 'package:holdem/utils/api.dart';
import 'package:holdem/utils/http_utils.dart';

class NetRequest {
  Future getBoardList() async{
    var data = await HttpUtils.get(Api.boardList);
    print(data);
    return data;
  }
}