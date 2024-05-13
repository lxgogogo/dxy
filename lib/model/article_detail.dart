class ArticleDetailBean {
  ArticleCategoryBean? category;
  int? categoryId;
  String? cover;
  int? commentCount;
  String? createdAt;
  int? favoriteCount;
  bool? favorited;
  int? id;
  int? likeCount;
  int? listId;
  String? title;
  String? type;
  String? updatedAt;
  VideoBean? video;
  BookBean? book;

  ArticleDetailBean(
      {this.category,
      this.categoryId,
      this.cover,
      this.commentCount,
      this.createdAt,
      this.favoriteCount,
      this.favorited,
      this.id,
      this.likeCount,
      this.listId,
      this.title,
      this.type,
      this.updatedAt,
      this.video,
      this.book});

  ArticleDetailBean.fromJson(Map<String, dynamic> json) {
    if (json["category"] is Map) {
      category = ArticleCategoryBean.fromJson(json["category"]);
    }
    if (json["category_id"] is int) {
      categoryId = json["categoryId"];
    }
    if (json["cover"] is String) {
      cover = json["cover"];
    }
    if (json["commentCount"] is int) {
      commentCount = json["commentCount"];
    }
    if (json["createdAt"] is String) {
      createdAt = json["createdAt"];
    }
    if (json["favoriteCount"] is int) {
      favoriteCount = json["favoriteCount"];
    }
    if (json["favorited"] is bool) {
      favorited = json["favorited"];
    }
    if (json["id"] is int) {
      id = json["id"];
    }
    if (json["likeCount"] is int) {
      likeCount = json["likeCount"];
    }
    if (json["listId"] is int) {
      listId = json["listId"];
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
    if (json["video"] is Map) {
      video = VideoBean.fromJson(json["video"]);
    }
    if (json["book"] is Map){
      book = BookBean.fromJson(json["book"]);
    }
  }
}

class ArticleCategoryBean {
  int? id;
  String? name;
  String? alias;

  ArticleCategoryBean({this.id, this.name, this.alias});

  ArticleCategoryBean.fromJson(Map<String, dynamic> json) {
    if (json["id"] is int) {
      id = json["id"];
    }
    if (json["name"] is String) {
      name = json["name"];
    }
    if (json["alias"] is String) {
      alias = json["alias"];
    }
  }
}

class BookBean {
  int? id;
  String? downloadUrl;
  String? publishDate;
  String? publisher;

  BookBean({this.id, this.downloadUrl, this.publishDate, this.publisher});

  BookBean.fromJson(Map<String, dynamic> json) {
    if (json["id"] is int) {
      id = json["id"];
    }
    if (json["downloadUrl"] is String) {
      downloadUrl = json["downloadUrl"];
    }
    if (json["publishDate"] is String) {
      publishDate = json["publishDate"];
    }
    if (json["publisher"] is String) {
      publisher = json["publisher"];
    }
  }
}

class VideoBean {
  int? duration;
  int? id;
  int? num;
  String? quality;
  String? sourceUrl;

  VideoBean({this.duration, this.id, this.num, this.quality, this.sourceUrl});

  VideoBean.fromJson(Map<String, dynamic> json) {
    if (json["duration"] is int) {
      duration = json["duration"];
    }
    if (json["id"] is int) {
      id = json["id"];
    }
    if (json["num"] is int) {
      num = json["num"];
    }
    if (json["quality"] is String) {
      quality = json["quality"];
    }
    if (json["sourceUrl"] is String) {
      sourceUrl = json["sourceUrl"];
    }
  }
}
