import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
import '../utils/toast_utils.dart';

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
        borderRadius: 10.5.r,
        margin: EdgeInsets.symmetric(horizontal: 24.w),
        child: Container(
          padding: EdgeInsets.only(top: 35.w, bottom: 20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SvgPicture.asset(
                "assets/svg/icon_warning.svg",
                width: 46.w,
                height: 46.w,
              ),
              SizedBox(height: 25.w),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xff5f75a0),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 36.w),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 22.w),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        height: 42.w,
                        title: '取消',
                        isCancel: true,
                        textColor: const Color(0xff95a3c4),
                      ),
                    ),
                    SizedBox(width: 15.w),
                    Expanded(
                      child: CustomButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        height: 42.w,
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
