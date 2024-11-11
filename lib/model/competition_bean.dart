import 'dart:convert';

import 'package:holdem/model/article.dart';
import 'package:holdem/model/board_list.dart';

class CompetitionBean {
  int? id;
  String? type;
  int? listId;
  int? categoryId;
  String? title;
  String? description;
  String? cover;
  String? author;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? commentCount;
  int? favoriteCount;
  int? likeCount;
  int? viewCount;
  int? shareCount;
  Category? category;
  Competition? competition;
  bool? liked;
  bool? favorited;
  List<ArticleBean>? refArticleList;
  List<ArticleBean>? refVideoList;
  List<BoardBean>? refThreadList;
  Article? article;

  CompetitionBean({
    this.id,
    this.type,
    this.listId,
    this.categoryId,
    this.title,
    this.description,
    this.cover,
    this.author,
    this.createdAt,
    this.updatedAt,
    this.commentCount,
    this.favoriteCount,
    this.likeCount,
    this.viewCount,
    this.shareCount,
    this.category,
    this.competition,
    this.liked,
    this.favorited,
    this.refArticleList,
    this.refVideoList,
    this.refThreadList,
    this.article,
  });

  factory CompetitionBean.fromRawJson(String str) => CompetitionBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CompetitionBean.fromJson(Map<String, dynamic> json) => CompetitionBean(
    id: json["id"],
    type: json["type"],
    listId: json["listId"],
    categoryId: json["categoryId"],
    title: json["title"],
    description: json["description"],
    cover: json["cover"],
    author: json["author"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    commentCount: json["commentCount"],
    favoriteCount: json["favoriteCount"],
    likeCount: json["likeCount"],
    viewCount: json["viewCount"],
    shareCount: json["shareCount"],
    category: json["category"] == null ? null : Category.fromJson(json["category"]),
    competition: json["competition"] == null ? null : Competition.fromJson(json["competition"]),
    liked: json["liked"],
    favorited: json["favorited"],
    refArticleList: json["refArticleList"] == null ? [] : List<ArticleBean>.from(json["refArticleList"]!.map((x) => ArticleBean.fromJson(x))),
    refVideoList: json["refVideoList"] == null ? [] : List<ArticleBean>.from(json["refVideoList"]!.map((x) => ArticleBean.fromJson(x))),
    refThreadList: json["refThreadList"] == null ? [] : List<BoardBean>.from(json["refThreadList"]!.map((x) => BoardBean.fromJson(x))),
    article: json["article"] == null ? null : Article.fromJson(json["article"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "listId": listId,
    "categoryId": categoryId,
    "title": title,
    "description": description,
    "cover": cover,
    "author": author,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "commentCount": commentCount,
    "favoriteCount": favoriteCount,
    "likeCount": likeCount,
    "viewCount": viewCount,
    "shareCount": shareCount,
    "category": category?.toJson(),
    "competition": competition?.toJson(),
    "liked": liked,
    "favorited": favorited,
    "refArticleList": refArticleList == null ? [] : List<dynamic>.from(refArticleList!.map((x) => x.toJson())),
    "refVideoList": refVideoList == null ? [] : List<dynamic>.from(refVideoList!.map((x) => x)),
    "refThreadList": refThreadList == null ? [] : List<dynamic>.from(refThreadList!.map((x) => x.toJson())),
    "article": article?.toJson(),
  };
}

class Article {
  int? id;
  String? content;

  Article({
    this.id,
    this.content,
  });

  factory Article.fromRawJson(String str) => Article.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Article.fromJson(Map<String, dynamic> json) => Article(
    id: json["id"],
    content: json["content"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "content": content,
  };
}

class Category {
  int? id;
  String? name;
  String? alias;

  Category({
    this.id,
    this.name,
    this.alias,
  });

  factory Category.fromRawJson(String str) => Category.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"],
    name: json["name"],
    alias: json["alias"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "alias": alias,
  };
}

class Competition {
  int? id;
  int? duration;
  String? thumbnail;
  String? place;
  String? content;
  DateTime? dayBegin;
  DateTime? dayEnd;
  DateTime? mainDayBegin;
  DateTime? mainDayEnd;
  int? loop;
  String? sourceUrl;
  String? searchKeywords;

  Competition({
    this.id,
    this.duration,
    this.thumbnail,
    this.place,
    this.content,
    this.dayBegin,
    this.dayEnd,
    this.mainDayBegin,
    this.mainDayEnd,
    this.loop,
    this.sourceUrl,
    this.searchKeywords,
  });

  factory Competition.fromRawJson(String str) => Competition.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Competition.fromJson(Map<String, dynamic> json) => Competition(
    id: json["id"],
    duration: json["duration"],
    thumbnail: json["thumbnail"],
    place: json["place"],
    content: json["content"],
    dayBegin: json["dayBegin"] == null ? null : DateTime.parse(json["dayBegin"]),
    dayEnd: json["dayEnd"] == null ? null : DateTime.parse(json["dayEnd"]),
    mainDayBegin: json["mainDayBegin"] == null ? null : DateTime.parse(json["mainDayBegin"]),
    mainDayEnd: json["mainDayEnd"] == null ? null : DateTime.parse(json["mainDayEnd"]),
    loop: json["loop"],
    sourceUrl: json["sourceUrl"],
    searchKeywords: json["searchKeywords"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "duration": duration,
    "thumbnail": thumbnail,
    "place": place,
    "content": content,
    "dayBegin": dayBegin?.toIso8601String(),
    "dayEnd": dayEnd?.toIso8601String(),
    "mainDayBegin": mainDayBegin?.toIso8601String(),
    "mainDayEnd": mainDayEnd?.toIso8601String(),
    "loop": loop,
    "sourceUrl": sourceUrl,
    "searchKeywords": searchKeywords,
  };
}

class RefThreadList {
  int? id;
  int? userId;
  int? adminId;
  int? boardId;
  String? title;
  List<dynamic>? tags;
  List<dynamic>? files;
  List<dynamic>? at;
  String? content;
  int? top;
  int? commentCount;
  int? favoriteCount;
  int? likeCount;
  int? shareCount;
  int? viewCount;
  dynamic sourceUrl;
  int? sort;
  List<Sign>? sign;
  int? locked;
  DateTime? deletedAt;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic adminName;

  RefThreadList({
    this.id,
    this.userId,
    this.adminId,
    this.boardId,
    this.title,
    this.tags,
    this.files,
    this.at,
    this.content,
    this.top,
    this.commentCount,
    this.favoriteCount,
    this.likeCount,
    this.shareCount,
    this.viewCount,
    this.sourceUrl,
    this.sort,
    this.sign,
    this.locked,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.adminName,
  });

  factory RefThreadList.fromRawJson(String str) => RefThreadList.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RefThreadList.fromJson(Map<String, dynamic> json) => RefThreadList(
    id: json["id"],
    userId: json["userId"],
    adminId: json["adminId"],
    boardId: json["boardId"],
    title: json["title"],
    tags: json["tags"] == null ? [] : List<dynamic>.from(json["tags"]!.map((x) => x)),
    files: json["files"] == null ? [] : List<dynamic>.from(json["files"]!.map((x) => x)),
    at: json["at"] == null ? [] : List<dynamic>.from(json["at"]!.map((x) => x)),
    content: json["content"],
    top: json["top"],
    commentCount: json["commentCount"],
    favoriteCount: json["favoriteCount"],
    likeCount: json["likeCount"],
    shareCount: json["shareCount"],
    viewCount: json["viewCount"],
    sourceUrl: json["sourceUrl"],
    sort: json["sort"],
    sign: json["sign"] == null ? [] : List<Sign>.from(json["sign"]!.map((x) => Sign.fromJson(x))),
    locked: json["locked"],
    deletedAt: json["deletedAt"] == null ? null : DateTime.parse(json["deletedAt"]),
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    adminName: json["adminName"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "adminId": adminId,
    "boardId": boardId,
    "title": title,
    "tags": tags == null ? [] : List<dynamic>.from(tags!.map((x) => x)),
    "files": files == null ? [] : List<dynamic>.from(files!.map((x) => x)),
    "at": at == null ? [] : List<dynamic>.from(at!.map((x) => x)),
    "content": content,
    "top": top,
    "commentCount": commentCount,
    "favoriteCount": favoriteCount,
    "likeCount": likeCount,
    "shareCount": shareCount,
    "viewCount": viewCount,
    "sourceUrl": sourceUrl,
    "sort": sort,
    "sign": sign == null ? [] : List<dynamic>.from(sign!.map((x) => x.toJson())),
    "locked": locked,
    "deletedAt": deletedAt?.toIso8601String(),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "adminName": adminName,
  };
}

class Sign {
  int? id;
  String? tag;
  String? name;

  Sign({
    this.id,
    this.tag,
    this.name,
  });

  factory Sign.fromRawJson(String str) => Sign.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Sign.fromJson(Map<String, dynamic> json) => Sign(
    id: json["id"],
    tag: json["tag"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "tag": tag,
    "name": name,
  };
}
