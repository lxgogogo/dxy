import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MessageTabChildPage extends StatefulWidget {
  int tabId;
  MessageTabChildPage({super.key,required this.tabId});

  @override
  State<MessageTabChildPage> createState() => _MessageTabChildPageState();
}

class _MessageTabChildPageState extends State<MessageTabChildPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('hi'),
    );
  }
}