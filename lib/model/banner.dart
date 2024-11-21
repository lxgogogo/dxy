class BannerBean {
  String? title;
  String? img;
  String? imgMobile;
  String? jumpValue;
  String? jumpType;
  int? sort;
  int? status;
  DateTime? createdAt;

  BannerBean(
      {this.title,
      this.img,
      this.imgMobile,
      this.jumpValue,
      this.jumpType,
      this.sort,
      this.status,
      this.createdAt});

  BannerBean.fromJson(Map<String, dynamic> json) {
    if (json["title"] is String) {
      title = json["title"];
    }
    if (json["img"] is String) {
      img = json["img"];
    }
    if (json["imgMobile"] is String) {
      imgMobile = json["imgMobile"];
    }
    if (json["jumpValue"] is String) {
      jumpValue = json["jumpValue"];
    }
    if (json["jumpType"] is String) {
      jumpType = json["jumpType"];
    }
    if (json["sort"] is int) {
      sort = json["sort"];
    }
    if (json["status"] is int) {
      status = json["status"];
    }
    if (json["createdAt"] is String) {
      createdAt = DateTime.parse(json["createdAt"]).toLocal();
    }
  }
}
