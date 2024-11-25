import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/utils/storage.dart';
import 'package:holdem/widget/button.dart';
import 'package:holdem/widget/shadow_wrapper.dart';
import 'package:oktoast/oktoast.dart';

import '../../utils/app_theme.dart';
import '../../utils/eventbus/EventBusAction.dart';
import '../../utils/eventbus/EventBusManager.dart';
import '../../view/forum/ToastUtils.dart';

class DialogConfirm extends StatelessWidget {
  final String title;

  const DialogConfirm({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: Alignment.center,
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: ShadowWrapper(
        borderRadius: 10.5.px,
        margin: EdgeInsets.only(left: 18.px, right: 18.px),
        child: Container(
          padding: EdgeInsets.only(top: 35.px, bottom: 20.px),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SvgPicture.asset(
                "assets/svg/icon_warning.svg",
                width: 46.px,
                height: 46.px,
              ),
              SizedBox(height: 25.px),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.px),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xff5f75a0),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 36.px),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 22.px),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        height: 42.px,
                        title: '取消',
                        isCancel: true,
                        textColor: const Color(0xff95a3c4),
                      ),
                    ),
                    SizedBox(width: 15.px),
                    Expanded(
                      child: CustomButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        height: 42.px,
                        title: '确认',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
