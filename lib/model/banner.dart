class BannerBean{
  String? title;
  String? img;
  String? jumpValue;
  String? jumpType;
  int? sort;
  int? status;
  DateTime? createdAt;

  BannerBean({this.title, this.img, this.jumpValue, this.jumpType, this.sort, this.status, this.createdAt});

  factory BannerBean.fromJson(Map<String, dynamic> json){
    return BannerBean(
      title: json['title'],
      img: json['img'],
      jumpValue: json['jumpValue'],
      jumpType: json['jumpType'],
      sort: json['sort'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt'])
    );
  }
}