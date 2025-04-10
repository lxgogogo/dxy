import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/utils/toast_utils.dart';
import 'package:holdem/widget/common_app_bar.dart';
import 'package:holdem/widget/dialog_delete_account.dart';
import 'package:holdem/widget/dialog_edit_email.dart';
import 'package:holdem/widget/dialog_edit_nickname.dart';
import 'package:image_picker/image_picker.dart';

import '../../model/user.dart';
import '../../services/index.dart';
import '../../stores/user_store.dart';
import '../../utils/net_request.dart';
import '../../widget/dialog_edit_mobile.dart';
import '../../widget/dialog_edit_username.dart';
import '../../widget/dialog_new_tip.dart';

part 'personal_controller.dart';

class PersonalScreen extends StatefulWidget {
  const PersonalScreen({Key? key}) : super(key: key);

  @override
  State<PersonalScreen> createState() => _PersonalScreenState();
}

class _PersonalScreenState extends State<PersonalScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<PersonalScreenController>(
      init: PersonalScreenController(),
      builder: (controller) {
        return Scaffold(
          appBar: CommonAppBar.arrowBack(context, title: '个人资料'),
          backgroundColor: '#F7F8FC'.hexColor,
          body: Obx(
            () {
              return Column(
                children: [
                  SizedBox(
                    height: 23.5.w,
                  ),
                  SizedBox(
                    width: 88.w,
                    height: 88.w,
                    child: ClipOval(
                      child: IndexedStack(
                        index: controller.imageUrl.isNotEmpty ? 0 : 1,

                        /// 保留新netImage渲染,返回后也能加快加载
                        sizing: StackFit.expand,
                        children: [
                          Image.file(
                            File(controller.imageUrl),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Assets.images.imageLoadingDef.image(
                              fit: BoxFit.fill,
                            ),
                          ),
                          CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: UserStore.of.user?.avatar ?? '',
                            cacheKey: UserStore.of.user?.avatar ?? '',
                            placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                              color: Colors.white,
                            )),
                            errorWidget: (_, __, ___) => Assets.images.imageLoadingDef.image(
                              fit: BoxFit.fill,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12.w),
                  GestureDetector(
                    onTap: controller.selectImage,
                    child: Container(
                      width: 72.w,
                      height: 30.w,
                      decoration: ShapeDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF557BF6),
                            Color(0xFF84BCF9),
                          ],
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '修改头像',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(12.w).copyWith(top: 0),
                      margin: EdgeInsets.only(top: 16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildRowItem(
                                    label: '昵称',
                                    value: UserStore.of.user?.nickname ?? '',
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => DialogEditNickname(
                                          editContent: UserStore.of.user?.nickname ?? '',
                                        ),
                                      );
                                    },
                                  ),
                                  Container(
                                    color: const Color(0xffe6e6e6),
                                    height: 0.5.w,
                                  ),
                                  _buildRowItem(
                                    label: '账号',
                                    value: UserStore.of.user?.username ?? '',
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => DialogEditUsername(
                                          editContent: UserStore.of.user?.username ?? '',
                                        ),
                                      ).then((errorTip) {
                                        if (errorTip is String) {
                                          if (!context.mounted) return;
                                          showDialog(
                                            context: context,
                                            builder: (context) => DialogNewTip(
                                              title: '绑定失败',
                                              content: errorTip,
                                            ),
                                          );
                                        }
                                      });
                                    },
                                  ),
                                  Container(
                                    color: const Color(0xffe6e6e6),
                                    height: 0.5.w,
                                  ),
                                  _buildRowItem(
                                    label: '邮箱',
                                    value: UserStore.of.user?.account ?? '',
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => DialogEditEmail(
                                          editContent: UserStore.of.user?.account ?? '',
                                        ),
                                      ).then((errorTip) {
                                        if (errorTip is String) {
                                          if (!context.mounted) return;
                                          showDialog(
                                            context: context,
                                            builder: (context) => DialogNewTip(
                                              title: '绑定失败',
                                              content: errorTip,
                                            ),
                                          );
                                        }
                                      });
                                    },
                                  ),
                                  Container(
                                    color: const Color(0xffe6e6e6),
                                    height: 0.5.w,
                                  ),
                                  _buildRowItem(
                                    label: '手机号',
                                    value: UserStore.of.user?.phone ?? '',
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => DialogEditMobile(
                                          editContent: UserStore.of.user?.phone ?? '',
                                        ),
                                      ).then((errorTip) {
                                        if (errorTip is String) {
                                          if (!context.mounted) return;
                                          showDialog(
                                            context: context,
                                            builder: (context) => DialogNewTip(
                                              title: '绑定失败',
                                              content: errorTip,
                                            ),
                                          );
                                        }
                                      });
                                    },
                                  ),
                                  SizedBox(height: 32.w),
                                  Text(
                                    '第三方账号绑定',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      color: '#333333'.hexColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 16.w),
                                  _buildRowButtonItem(
                                    genImage: Assets.images.iconGoogle,
                                    label: 'Google',
                                    onTap: () {
                                      if (UserStore.of.user?.googleAccount?.isNotEmpty == true) return;
                                      controller.signInWithGoogle();
                                    },
                                    isBind: UserStore.of.user?.googleAccount?.isNotEmpty == true,
                                  ),
                                  Container(
                                    color: const Color(0xffe6e6e6),
                                    height: 0.5.w,
                                  ),
                                  _buildRowButtonItem(
                                    genImage: Assets.images.iconApple,
                                    label: 'Apple',
                                    onTap: () {
                                      if (UserStore.of.user?.appleAccount?.isNotEmpty == true) return;
                                      controller.signInWithApple();
                                    },
                                    isBind: UserStore.of.user?.appleAccount?.isNotEmpty == true,
                                  ),
                                  Container(
                                    color: const Color(0xffe6e6e6),
                                    height: 0.5.w,
                                  ),
                                  _buildRowButtonItem(
                                    genImage: Assets.images.iconTelegram,
                                    label: 'Telegram',
                                    onTap: () {
                                      if (UserStore.of.user?.telegramAccount?.isNotEmpty == true) return;
                                      controller.signInWithTelegram();
                                    },
                                    isBind: UserStore.of.user?.telegramAccount?.isNotEmpty == true,
                                  ),
                                  Container(
                                    color: const Color(0xffe6e6e6),
                                    height: 0.5.w,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 16.w),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => const DialogDeleteAccount(),
                              );
                            },
                            behavior: HitTestBehavior.translucent,
                            child: Text(
                              '注销账号',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: '#FF3333'.hexColor,
                              ),
                            ),
                          ),
                          SizedBox(height: 70.w)
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  GestureDetector _buildRowItem({
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Container(
        height: 44.w,
        alignment: Alignment.center,
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: '#333333'.hexColor,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  color: '#333333'.hexColor,
                  fontSize: 14.sp,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Image.asset(
              'assets/images/edit_password.png',
              width: 12.w,
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector _buildRowButtonItem({
    required AssetGenImage genImage,
    required String label,
    VoidCallback? onTap,
    bool isBind = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52.w,
        alignment: Alignment.center,
        child: Row(
          children: [
            genImage.image(width: 28.w, height: 28.w),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                color: '#333333'.hexColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onTap,
              child: Container(
                width: 60.w,
                height: 24.w,
                decoration: ShapeDecoration(
                  color: isBind ? '#333333'.hexColor.withOpacity(0.1) : null,
                  gradient: isBind
                      ? null
                      : const LinearGradient(
                          colors: [
                            Color(0xFF557BF6),
                            Color(0xFF84BCF9),
                          ],
                        ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  isBind ? '已绑定' : '绑定',
                  style: TextStyle(
                    color: isBind ? '#333333'.hexColor : Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
