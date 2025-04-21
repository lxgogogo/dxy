
class MessageNoticeModel {

  int? id;
  int? type;
  String? sendUserHeadimg;
  String? sendUserName;
  String? title;
  String? content;
  String? createdAt;
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

  factory MessageNoticeModel.fromJson(Map<String, dynamic> json) => MessageNoticeModel(
    id: json["id"],
    type: json["type"],
    sendUserHeadimg: json["sendUserHeadimg"],
    sendUserName: json["sendUserName"],
    title: json["title"],
    content: json["content"],
    createdAt: json["createdAt"],
    isDel: json["isDel"],
  );

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