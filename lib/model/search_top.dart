// To parse this JSON data, do
//
//     final searchTop = searchTopFromMap(jsonString);

import 'dart:convert';

SearchTop searchTopFromMap(String str) => SearchTop.fromMap(json.decode(str));

String searchTopToMap(SearchTop data) => json.encode(data.toMap());

class SearchTop {
  final int? id;
  final String? title;
  final double? popularCount;
  final String? type;
  final DateTime? createdAt;

  SearchTop({
    this.id,
    this.title,
    this.popularCount,
    this.type,
    this.createdAt,
  });

  SearchTop copyWith({
    int? id,
    String? title,
    double? popularCount,
    String? type,
    DateTime? createdAt,
  }) =>
      SearchTop(
        id: id ?? this.id,
        title: title ?? this.title,
        popularCount: popularCount ?? this.popularCount,
        type: type ?? this.type,
        createdAt: createdAt ?? this.createdAt,
      );

  factory SearchTop.fromMap(Map<String, dynamic> json) => SearchTop(
    id: json["id"],
    title: json["title"],
    popularCount: json["popularCount"]?.toDouble(),
    type: json["type"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "title": title,
    "popularCount": popularCount,
    "type": type,
    "createdAt": createdAt?.toIso8601String(),
  };
}
