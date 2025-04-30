import 'package:holdem/model/tag_model.dart';
import 'package:holdem/model/user.dart';

class ArticleDetailBean {
  ArticleCategoryBean? category;
  ArticleContent? article;
  String? author;
  int? categoryId;
  String? cover;
  int? commentCount;
  int? shareCount;
  DateTime? createdAt;
  int? favoriteCount;
  bool? favorited;
  bool? liked;
  int? id;
  int? likeCount;
  int? viewCount;
  int? listId;
  String? title;
  String? description;
  String? type;
  DateTime? updatedAt;
  VideoBean? video;
  BookBean? book;
  ToolBean? tool;
  UserProfile? user;
  List<VideoBean>? videoList;
  List<TagModel>? tagList;
  UserLevel? userlevel;
  int? featured;


  ArticleDetailBean({
    this.category,
    this.article,
    this.author,
    this.categoryId,
    this.cover,
    this.commentCount,
    this.shareCount,
    this.createdAt,
    this.favoriteCount,
    this.favorited,
    this.liked,
    this.id,
    this.likeCount,
    this.viewCount,
    this.listId,
    this.title,
    this.description,
    this.type,
    this.updatedAt,
    this.video,
    this.book,
    this.user,
    this.videoList,
    this.tagList,
    this.userlevel,
    this.featured
  });

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
    if (json["shareCount"] is int) {
      shareCount = json["shareCount"];
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
    if (json["liked"] is bool) {
      liked = json["liked"];
    }
    if (json["id"] is int) {
      id = json["id"];
    }
    if (json["likeCount"] is int) {
      likeCount = json["likeCount"];
    }
    if (json["viewCount"] is int) {
      viewCount = json["viewCount"];
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
    if (json["book"] is Map) {
      book = BookBean.fromJson(json["book"]);
    }
    if (json["tool"] is Map) {
      tool = ToolBean.fromJson(json["tool"]);
    }
    if (json['user'] != null) {
      user = UserProfile.fromJson(json['user']);
    }
    if (json["videoList"] is List) {
      videoList =
      json["videoList"] == null ? null : (json["videoList"] as List).map((e) => VideoBean.fromJson(e)).toList();
    }
    if (json["tagList"] is List) {
      tagList = json["tagList"] == null ? null : (json["tagList"] as List).map((e) => TagModel.fromJson(e)).toList();
    }
    if (json["userLevel"] is Map) {
      userlevel = UserLevel.fromJson(json["userLevel"]);
    }
    if (json["featured"] is int) {
      featured = json["featured"];
    }
  }
}

class ArticleContent {
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

class ToolBean {
  int? id;
  String? url;
  String? androidUrl;
  String? iosUrl;

  ToolBean({this.id, this.url, this.androidUrl, this.iosUrl});

  ToolBean.fromJson(Map<String, dynamic> json) {
    if (json["id"] is int) {
      id = json["id"];
    }
    if (json["url"] is String) {
      url = json["url"];
    }
    if (json["androidUrl"] is String) {
      androidUrl = json["androidUrl"];
    }
    if (json["iosUrl"] is String) {
      iosUrl = json["iosUrl"];
    }
  }
}

class VideoBean {
  int? duration;
  int? id;
  int? num;
  String? title;
  String? quality;
  String? sourceUrl;

  VideoBean({this.duration, this.id, this.num, this.title, this.quality, this.sourceUrl});

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
    if (json["title"] is String) {
      title = json["title"];
    }
    if (json["quality"] is String) {
      quality = json["quality"];
    }
    if (json["sourceUrl"] is String) {
      sourceUrl = json["sourceUrl"];
    }
  }
}

class UserLevel {
  int? favoriteCategory;
  int? id;
  String? name;

  ///观看引流广告 0:否  1:是
  int? advertise;

  int? featured;
  int? videoWatch;
  int? bookDownload;

  UserLevel({this.featured, this.videoWatch, this.bookDownload});

  UserLevel.fromJson(Map<String, dynamic> json) {
    if (json["featured"] is int) {
      featured = json["featured"];
    }
    if (json["videoWatch"] is int) {
      videoWatch = json["videoWatch"];
    }
    if (json["bookDownload"] is int) {
      bookDownload = json["bookDownload"];
    }
    if (json["favoriteCategory"] is int) {
      favoriteCategory = json["favoriteCategory"];
    }
    if (json["id"] is int) {
      id = json["id"];
    }
    if (json["name"] is String) {
      name = json["name"];
    }
    if (json["advertise"] is int) {
      advertise = json["advertise"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["featured"] = featured;
    _data["videoWatch"] = videoWatch;
    _data["bookDownload"] = bookDownload;
    _data["favoriteCategory"] = favoriteCategory;
    _data["id"] = id;
    _data["name"] = name;
    _data["advertise"] = advertise;
    return _data;
  }
}
