import 'package:dynamic_tabbar/dynamic_tabbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:holdem/page/forum/page_forum_tab_child.dart';
import 'package:holdem/utils/size_fit.dart';

import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../view/forum/ToastUtils.dart';

class CommentInputPage extends StatefulWidget {
  int postId; //帖子id
  CommentInputPage({super.key, required this.postId});

  @override
  State<CommentInputPage> createState() => _CommentInputPageState();
}

class _CommentInputPageState extends State<CommentInputPage>
    with SingleTickerProviderStateMixin {
  late int currentPostId;
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentPostId = widget.postId;
  }

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset(
            'assets/images/back.png',
            width: 22.px,
            height: 22.px,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        title: const Text(
          '评论',
          style: AppTheme.text333333Size17,
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            color: AppTheme.color_F3F3F3,
            thickness: 1,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                //提交评论
                String text = controller.text;
                if (text.isNotEmpty) {
                  ToastUtils.showToast( '提交服务器:$text');
                } else {
                  ToastUtils.showToast('评论内容不能为空');
                }
              },
              icon: Image.asset(
                'assets/images/publish.png',
                width: 50.px,
                height: 29.px,
              ))
        ],
      ),
      body: SafeArea(child: contentView()),
      backgroundColor: Colors.white,
    );
  }

  Widget contentView() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 15, 16, 0),
      height: 180.px,
      child: TextFormField(
        maxLines: null, // 允许自动换行
        minLines: 8,
        controller: controller,
        decoration: InputDecoration(
          hintText: '我来说两句',
          hintStyle: AppTheme.text999999Size16,
          fillColor: AppTheme.color_50000000,
          filled: true,
          // border: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(6),
          //   borderSide: BorderSide(
          //     color: AppTheme.color_0D000000,
          //     width: 2.0,
          //   ),
          // ),
          contentPadding: EdgeInsets.all(10),
          // 文本从左上角开始
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppTheme.color_1A000000, width: 1),
            borderRadius: BorderRadius.circular(6.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppTheme.color_1A000000, width: 1),
            borderRadius: BorderRadius.circular(6.0),
          ),
        ),
      ),
    );
  }
}
