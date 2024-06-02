import 'package:flutter/material.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';

import '../../utils/app_theme.dart';
import '../../utils/eventbus/EventBusAction.dart';
import '../../utils/eventbus/EventBusManager.dart';
import '../../view/forum/ToastUtils.dart';
import '../../widget/page_web_fit.dart';

class InformationEditPage extends StatefulWidget {
  String editContent; //
  InformationEditPage({super.key, required this.editContent});

  @override
  State<InformationEditPage> createState() => _InformationEditPageState();
}

class _InformationEditPageState extends State<InformationEditPage>
    with SingleTickerProviderStateMixin {
  late String editContent;
  bool isTextFiledIsEmpty = false;

  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    editContent = widget.editContent;
    controller.text = editContent;
  }

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return  WebFitPage(child: Scaffold(
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
          '编辑昵称',
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
                //提交
                _submitUpdate();
              },
              icon: Image.asset(
                isTextFiledIsEmpty
                    ? 'assets/images/finish_disable.png'
                    : 'assets/images/finish_enable.png',
                width: 50.px,
                height: 29.px,
              ))
        ],
      ),
      body: SafeArea(child: contentView()),
      backgroundColor: Colors.white,
    ));
  }

  void _submitUpdate() {
    String nickname = controller.text;
    if (isTextFiledIsEmpty) {
      return;
    }
    NetRequest().userUpdate(nickname, (data) {
      ToastUtils.showToast('修改成功');
      //通知各页面刷新
      EventBusManager.eventBus
          .fire(EventBusAction.refreshPersonalProfile.eventBusTypeName);
      Navigator.pop(context);
    });
  }

  Widget contentView() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 5, 16, 0),
      height: 45.px,
      child: TextFormField(
        maxLines: 1, //
        minLines: 1,
        controller: controller,
        onChanged: (value) {
          if (mounted) {
            setState(() {
              if (value.isEmpty) {
                isTextFiledIsEmpty = true;
              } else {
                isTextFiledIsEmpty = false;
              }
            });
          }
        },
        decoration: InputDecoration(
          hintText: '请输入昵称',
          hintStyle: AppTheme.text999999Size16,
          fillColor: AppTheme.color_50000000,
          filled: true,
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
