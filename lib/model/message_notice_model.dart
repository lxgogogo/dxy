
class MessageNoticeModel {

  int? id;
  int? type;
  String? sendUserHeadimg;
  String? sendUserName;
  String? title;
  String? content;
  DateTime? createdAt;
  int? isDel;

  MessageNoticeModel({
    this.id,
    this.type,
    this.sendUserHeadimg,
    this.sendUserName,
    this.title,
    this.content,
    this.createdAt,
    this.isDel,
  });

  factory MessageNoticeModel.fromJson(Map<String, dynamic> json) {
    DateTime? _createdat;
    if (json["createdAt"] is String) {
      String atStr = json["createdAt"] ?? '';
      if (atStr.isNotEmpty) {
        _createdat = DateTime.parse(atStr).toLocal();
      }
    } else {
      _createdat = json["createdAt"];
    }
    return MessageNoticeModel(
      id: json["id"],
      type: json["type"],
      sendUserHeadimg: json["sendUserHeadimg"],
      sendUserName: json["sendUserName"],
      title: json["title"],
      content: json["content"],
      createdAt: _createdat,
      isDel: json["isDel"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "sendUserHeadimg": sendUserHeadimg,
    "sendUserName": sendUserName,
    "title": title,
    "content": content,
    "createdAt": createdAt,
    "isDel": isDel
  };
}