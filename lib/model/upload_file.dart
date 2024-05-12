class UploadFile {
  String? type; //// image 图片， video视频
  String? path;
  String? url;
  // 只有视频有
  int? duration;
  String? posterPath;
  String? posterUrl;

  UploadFile({this.type, this.url, this.path, this.duration, this.posterPath,this.posterUrl });

  UploadFile.fromJson(Map<String, dynamic> json) {
    if (json["path"] is String) {
      path = json["path"];
    }
    if (json["url"] is String) {
      url = json["url"];
    }
    if (json["type"] is String) {
      type = json["type"];
    }
    if (json["duration"] is int) {
      duration = json["duration"];
    }
    if (json["posterPath"] is String) {
      posterPath = json["posterPath"];
    }
    if (json["posterUrl"] is String) {
      posterUrl = json["posterUrl"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["type"] = type;
    _data["path"] = path;
    _data["url"] = url;
    _data["duration"] = duration;
    _data["posterPath"] = posterPath;
    _data["posterUrl"] = posterUrl;
    return _data;
  }
}
