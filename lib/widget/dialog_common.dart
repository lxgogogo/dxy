import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/button.dart';
import 'package:holdem/widget/shadow_wrapper.dart';

class CommonDialog extends StatelessWidget {
  final String title;
  final VoidCallback? onConfirm;
  final String confirmText;
  final String cancelText;
  final bool onlyConfirm;

  const CommonDialog({
    super.key,
    required this.title,
    this.onConfirm,
    this.confirmText = '确定',
    this.cancelText = '取消',
    this.onlyConfirm = false,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !onlyConfirm,
      child: Dialog(
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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.px),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: const Color(0xff5f75a0),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 36.px),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 22.px),
                  child: Row(
                    children: [
                      if (!onlyConfirm)...[
                        Expanded(
                          child: CustomButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            height: 42.px,
                            title: cancelText,
                            isCancel: true,
                            textColor: const Color(0xff95a3c4),
                          ),
                        ),
                        SizedBox(width: 15.px),
                      ],
                      Expanded(
                        child: CustomButton(
                          onPressed: () {
                            onConfirm?.call();
                          },
                          height: 42.px,
                          title: confirmText,
                        ),
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
}
