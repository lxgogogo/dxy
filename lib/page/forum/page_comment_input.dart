import 'package:dynamic_tabbar/dynamic_tabbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:holdem/page/forum/page_forum_tab_child.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/view/background_container.dart';

import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/eventbus/EventBusAction.dart';
import '../../utils/eventbus/EventBusManager.dart';
import '../../view/forum/ToastUtils.dart';
import '../../widget/page_web_fit.dart';

class CommentInputPage extends StatefulWidget {
  String relType; //// 评论对象类型
  int relId; //// 评论对象id

  CommentInputPage({super.key, required this.relType, required this.relId});

  @override
  State<CommentInputPage> createState() => _CommentInputPageState();
}

class _CommentInputPageState extends State<CommentInputPage>
    with SingleTickerProviderStateMixin {
  late String relType;
  late int relId;
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    relId = widget.relId;
    relType = widget.relType;
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
        child: Scaffold(
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
        backgroundColor: Colors.transparent,
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
          // GestureDetector(child: Container(
          //   width: 50.px,
          //   height: 24.px,
          //   color: Colors.red,
          //   child: Text('发布'),),),
          GestureDetector(
            onTap: () {
              String commentContent = controller.text;
              if (commentContent.isNotEmpty && commentContent.length >= 5) {
                _submitComment(commentContent);
              } else {
                ToastUtils.showToast('评论内容不能低于5个字符');
              }
            },
            child: Container(
              width: 50.px,
              height: 24.px,
              margin: EdgeInsets.only(right: 20.px),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.px),
                  color: Color(0xFF249CFC)),
                  // color: controller.text.length>0 ? Color(0xFF249CFC) : Color(0x80249CFC)),
              child: Text(
                '发布',
                style: TextStyle(color: Colors.white, fontSize: 12.px),
              ),
            ),
          ),
          // IconButton(
          //     onPressed: () {
          //       //提交评论
          //       String commentContent = controller.text;
          //       if (commentContent.isNotEmpty &&  commentContent.length >= 5) {
          //         _submitComment(commentContent);
          //       } else {
          //         ToastUtils.showToast('评论内容不能低于5个字符');
          //       }
          //     },

          //     icon: Image.asset(
          //       'assets/images/publish.png',
          //       width: 50.px,
          //       height: 29.px,
          //     ))
        ],
      ),
      backgroundColor: Colors.transparent,
      body: SafeArea(child: contentView()),
    ));
  }

  void _submitComment(String commentContent) {
    NetRequest().commentCreate(relType, relId, commentContent, (data) {
      EventBusUtil.of.fire(EventRefreshComments(relType));
      ToastUtils.showToast('发布成功');
      Navigator.pop(context);
    });
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
