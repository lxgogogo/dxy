class ArticleBean{
  String? author;
  int? categoryId;
  int? commentCount;
  String? cover;
  String? createdAt;
  String? description;
  int? favoriteCount;
  int? id;
  int? likeCount;
  String? title;
  String? type;
  String? updatedAt;

  ArticleBean({this.author, this.categoryId, this.commentCount, this.cover, this.createdAt, this.description, this.favoriteCount, this.id, this.likeCount, this.title, this.type, this.updatedAt});

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
    if (json["cover"] is String) {
      cover = json["cover"];
    }
    if (json["createdAt"] is String) {
      createdAt = json["createdAt"];
    }
    if (json["description"] is String) {
      description = json["description"];
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
    if (json["title"] is String) {
      title = json["title"];
    }
    if (json["type"] is String) {
      type = json["type"];
    }
    if (json["updatedAt"] is String) {
      updatedAt = json["updatedAt"];
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
    _data["title"] = title;
    _data["type"] = type;
    _data["updated_at"] = updatedAt;

    return _data;
  }
}