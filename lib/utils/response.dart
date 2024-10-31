/// data : null
/// code : 401
/// message : "未登录"
/// error : null

class Response {
  int? code;
  String? message;

  Response({this.code, this.message});

  Response.fromJson(Map<dynamic, dynamic> json) {

    if(json["code"] is int) {
      code = json["code"];
    }
    if(json["message"] is String) {
      message = json["message"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["code"] = code;
    _data["message"] = message;
    return _data;
  }
}
