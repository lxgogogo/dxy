import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:holdem/utils/color_style_util.dart';
import 'package:holdem/utils/common_utils.dart';
import 'package:holdem/widget/button.dart';
import 'package:holdem/widget/common_app_bar.dart';

import 'points_conversion_controller.dart';

class PointsConversionPage extends StatefulWidget {
  const PointsConversionPage({Key? key}) : super(key: key);

  @override
  State<PointsConversionPage> createState() => _PointsConversionPageState();
}

class _PointsConversionPageState extends State<PointsConversionPage> {
  final PointsConversionController controller =
      Get.put(PointsConversionController());

  @override
  void dispose() {
    Get.delete<PointsConversionController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CommonAppBar.arrowBack(context, title: '积分兑换'),
        body: SafeArea(child: Obx(() {
          final dxyBalance = controller.dxyBalance.value;
          final dpkBalance = '${controller.pointsData['dpkBalance'] ?? 0.00}';
          return GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w).copyWith(top: 12.w),
              child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildCardWidget(
                                  '我的积分',
                                  CommonUtils.thousandthPercentile(dxyBalance,
                                      decimalLength: 2),
                                  'assets/images/icon_points_point.png',
                                  'assets/images/icon_points_go.png'),
                              SizedBox(height: 16.w),
                              _buildCardWidget(
                                  '德扑克金币',
                                  CommonUtils.thousandthPercentile(dpkBalance,
                                      decimalLength: 2),
                                  'assets/images/icon_points_coin.png',
                                  'assets/images/icon_points_come.png'),
                            ],
                          ),
                          Positioned(
                            top: 140.w,
                            left: (1.sw - 32.w) / 2,
                            child: Image.asset(
                              'assets/images/icon_points_change.png',
                              width: 32.w,
                              height: 32.w,
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 16.w),
                      Text(
                        '转换额度',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                            color: AppTheme.color_333333),
                      ),
                      SizedBox(height: 16.w),
                      _buildInPutWidget(),
                      SizedBox(height: 16.w),
                      _buildSwitchWidget(),
                      SizedBox(height: 84.w),
                      _buildButtonWidget()
                    ],
                  )),
            )
          );
        })));
  }

  Widget _buildCardWidget(
      String title, String value, String titleIcon, String rightIcon) {
    return Stack(
      children: [
        Container(
            height: 148.w,
            padding: EdgeInsets.only(left: 24.w, top: 24.w),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12.w)),
                color: AppTheme.color_333333.withOpacity(0.04)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      titleIcon,
                      width: 24.w,
                      height: 24.w,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      title,
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16.sp,
                          color: AppTheme.color_666666),
                    )
                  ],
                ),
                SizedBox(height: 24.w),
                Text(
                  value,
                  style: TextStyle(
                      fontSize: 32.sp,
                      color: AppTheme.color_333333,
                      fontWeight: FontWeight.w600),
                )
              ],
            )),
        Positioned(
            top: 0,
            right: 0,
            child: Image.asset(
              rightIcon,
              width: 46.w,
              height: 26.w,
            ))
      ],
    );
  }

  Widget _buildInPutWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            height: 44.w,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12.w)),
                color: AppTheme.color_333333.withOpacity(0.05)),
            child: Row(
              children: [
                Expanded(
                  child: _field(controller.textEditingController, '请输入转换额度',
                      onChanged: controller.textOnChanged),
                ),
                GestureDetector(
                  onTap: controller.allOnTap,
                  child: Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.only(left: 12.w),
                    child: Text(
                      '全部额度',
                      style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.color_557BF6),
                    ),
                  ),
                )
              ],
            )
        ),
        if (controller.tips.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 6.w),
            child: Text(
              controller.tips.value,
              style: TextStyle(
                  fontSize: 12.sp,
                  color: ColorStyle.cFF3333
              ),
            ),
          )
      ],
    );
  }

  Widget _buildSwitchWidget() {
    int coinAutoTransStatus = controller.coinAutoTransStatus.value;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '进入德扑克时自动带入积分',
          style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.color_666666),
        ),
        SizedBox(
          width: 40.w,
          child: Transform.scale(
            scale: 0.7,
            child: CupertinoSwitch(
                value: coinAutoTransStatus == 1 ? true : false,
                activeColor: '#34C759'.hexColor,
                onChanged: controller.onChanged),
          ),
        )
      ],
    );
  }

  Widget _buildButtonWidget() {
    return CustomButton(
      onPressed: controller.sureOnTap,
      disable: !controller.canTap.value,
      showOpacityAnimation: true,
      textColor: Colors.white,
      height: 50.w,
      radius: 8.w,
      title: '立即转换',
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
    );
  }

  TextField _field(TextEditingController textController, String hintText,
      {bool obscureText = false,
      Widget? prefix,
      bool enabled = true,
      FocusNode? focusNode,
      ValueChanged<String>? onChanged,
      VoidCallback? onEditingComplete}) {
    return TextField(
        cursorColor: ColorStyle.c557BF6,
        controller: textController,
        style: TextStyle(
          color: AppTheme.color_333333,
          fontSize: 14.w,
        ),
        enabled: enabled,
        focusNode: focusNode,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          // labelText: "手机号",
          border: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.transparent,
            ),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.transparent,
            ),
          ),
          disabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.transparent,
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.transparent,
            ),
          ),
          contentPadding: const EdgeInsets.only(top: 0, bottom: 0),
          // 去掉下滑线
          counterText: '',
          // 去除输入框底部的字符计数
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 12.w, color: AppTheme.color_999999),
          // prefix: prefix,
          prefixIcon: prefix,
        ),
        obscureText: obscureText,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp("[0-9]")),
        ]);
  }
}
