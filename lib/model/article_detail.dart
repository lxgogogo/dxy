import 'package:holdem/model/user.dart';

class ArticleDetailBean {
  ArticleCategoryBean? category;
  ArticleContent? article;
  String? author;
  int? categoryId;
  String? cover;
  int? commentCount;
  DateTime? createdAt;
  int? favoriteCount;
  bool? favorited;
  int? id;
  int? likeCount;
  int? listId;
  String? title;
  String? description;
  String? type;
  DateTime? updatedAt;
  VideoBean? video;
  BookBean? book;
  UserProfile? user;

  ArticleDetailBean(
      {this.category,
      this.article,
      this.author,
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
      this.description,
      this.type,
      this.updatedAt,
      this.video,
      this.book,
      this.user});

  ArticleDetailBean.fromJson(Map<String, dynamic> json) {
    if (json["category"] is Map) {
      category = ArticleCategoryBean.fromJson(json["category"]);
    }
    if (json["author"] is String) {
      author = json["author"];
    }
    if (json["article"] is Map) {
      article = ArticleContent.fromJson(json["article"]);
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
      createdAt = DateTime.parse(json["createdAt"]).toLocal();
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
    if (json["description"] is String) {
      description = json["description"];
    }
    if (json["type"] is String) {
      type = json["type"];
    }
    if (json["updatedAt"] is String) {
      updatedAt = DateTime.parse(json["updatedAt"]).toLocal();
    }
    if (json["video"] is Map) {
      video = VideoBean.fromJson(json["video"]);
    }
    if (json["book"] is Map){
      book = BookBean.fromJson(json["book"]);
    }
    if (json['user'] != null) {
      user = UserProfile.fromJson(json['user']);
    }
  }
}

class ArticleContent{
  int? id;
  String? content;

  ArticleContent({this.id, this.content});

  ArticleContent.fromJson(Map<String, dynamic> json) {
    if (json["id"] is int) {
      id = json["id"];
    }
    if (json["content"] is String) {
      content = json["content"];
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
  DateTime? publishDate;
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
      publishDate = DateTime.parse(json["publishDate"]).toLocal();
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
