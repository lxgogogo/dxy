import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/button.dart';
import 'package:holdem/widget/shadow_wrapper.dart';

import '../utils/app_theme.dart';
import '../utils/eventbus/EventBusAction.dart';
import '../utils/eventbus/EventBusManager.dart';
import '../utils/toast_utils.dart';

class DialogEditNickname extends StatefulWidget {
  final String editContent; //
  const DialogEditNickname({super.key, required this.editContent});

  @override
  State<DialogEditNickname> createState() => _DialogEditNicknameState();
}

class _DialogEditNicknameState extends State<DialogEditNickname> with SingleTickerProviderStateMixin {
  bool _isDisable = true;

  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.text = widget.editContent.length > 10 ? widget.editContent.substring(0, 10) : widget.editContent;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: Alignment.center,
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: ShadowWrapper(
          borderRadius: 10.5.px,
          margin: EdgeInsets.only(left: 18.px, right: 18.px),
          child: Container(
            padding: EdgeInsets.only(bottom: 26.px),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 72.px,
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          "修改昵称",
                          style: TextStyle(
                            color: const Color(0xff3b5078),
                            fontSize: 17.px,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10.px,
                      top: 10.px,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: SvgPicture.asset(
                          "assets/svg/icon_close.svg",
                          width: 28.px,
                          height: 28.px,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 21.5.px),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Text(
                            "昵称",
                            style: TextStyle(
                              color: const Color(0xff3b5078),
                              fontSize: 15.px,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 8.px),
                          Expanded(
                            child: Container(
                              height: 45.px,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.px),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xff709ac8).withOpacity(0.22),
                                  ),
                                  BoxShadow(
                                    color: const Color(0xffebf6ff),
                                    spreadRadius: -2.px,
                                    blurRadius: 5.px,
                                    offset: const Offset(1, 1),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: controller,
                                style: TextStyle(
                                  color: const Color(0xff3b5078),
                                  fontSize: 12.px,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                inputFormatters: <TextInputFormatter>[
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12.px),
                                  hintText: '请输入昵称',
                                  hintStyle: TextStyle(
                                    color: const Color(0xffa3b4d3),
                                    fontSize: 12.px,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(10.px),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(10.px),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(10.px),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Color(0xff2eacfb)),
                                    borderRadius: BorderRadius.circular(10.px),
                                  ),
                                ),
                                onChanged: (value) {
                                  _isDisable = value.isEmpty;
                                  setState(() {});
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 42.px),
                      CustomButton(
                        onPressed: _submitUpdate,
                        disable: _isDisable,
                        height: 42.px,
                        title: '确认',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitUpdate() {
    String nickname = controller.text;
    if (_isDisable) {
      return;
    }
    NetRequest().userUpdate(nickname, (data) {
      ToastUtils.showToast('修改成功');
      EventBusManager.eventBus.fire(EventBusAction.refreshPersonalProfile.eventBusTypeName);
      Navigator.pop(context);
    });
  }
}
