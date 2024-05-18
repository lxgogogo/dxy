import 'package:flutter/material.dart';

class SearchResultPage extends StatefulWidget {
  String keyword;
  SearchResultPage({super.key,required this.keyword});

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}