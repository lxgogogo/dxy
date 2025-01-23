import 'package:holdem/utils/html_parse_util.dart';

class ArticleBean {
  String? author;
  int? categoryId;
  int? commentCount;
  int? viewCount;
  String? cover;
  DateTime? createdAt;
  String? description;
  String? pureText;
  int? duration;
  int? favoriteCount;
  int? id;
  int? likeCount;
  int? shareCount;
  String? title;
  String? type;
  DateTime? updatedAt;

  ArticleBean(
      {this.author,
      this.categoryId,
      this.commentCount,
      this.viewCount,
      this.cover,
      this.createdAt,
      this.description,
      this.pureText,
      this.favoriteCount,
      this.id,
      this.likeCount,
      this.shareCount,
      this.title,
      this.type,
      this.updatedAt});

  ArticleBean.fromJson(Map<String, dynamic> json) {
    if (json["author"] is String) {
      author = json["author"];
    }
    if (json["category_id"] is num) {
      categoryId = json["category_id"];
    }
    if (json["commentCount"] is num) {
      commentCount = json["commentCount"];
    }
    if (json["viewCount"] is num) {
      viewCount = json["viewCount"];
    }
    if (json['duration'] is num) {
      duration = json['duration'];
    }
    if (json["cover"] is String) {
      cover = json["cover"];
    }
    if (json["createdAt"] is String) {
      createdAt = DateTime.parse(json["createdAt"]).toLocal();
    }
    if (json["description"] is String) {
      description = json["description"];
    }
    if (json["pureText"] is String) {
      pureText = json["pureText"];
    }
    if (json["description"] is String) {
      if (pureText?.isNotEmpty != true) {
        pureText = HtmlParseUtil.of.pureText(json["description"]);
      }
    }
    if (json["favoriteCount"] is num) {
      favoriteCount = json["favoriteCount"];
    }
    if (json["id"] is num) {
      id = json["id"];
    }
    if (json["likeCount"] is num) {
      likeCount = json["likeCount"];
    }
    if (json["shareCount"] is num) {
      shareCount = json["shareCount"];
    }
    if (json["title"] is String) {
      title = json["title"];
    }
    if (json["type"] is String) {
      type = json["type"];
    }
    if (json["updatedAt"] is String) {
      updatedAt = DateTime.parse(json["updatedAt"]).toLocal();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["author"] = author;
    _data["category_id"] = categoryId;
    _data["comment_count"] = commentCount;
    _data["cover"] = cover;
    _data["created_at"] = createdAt;
    _data["description"] = description;
    _data["favorite_count"] = favoriteCount;
    _data["id"] = id;
    _data["like_count"] = likeCount;
    _data["shareCount"] = shareCount;
    _data["title"] = title;
    _data["type"] = type;
    _data["updated_at"] = updatedAt;
    _data['duration'] = duration;

    return _data;
  }
}
