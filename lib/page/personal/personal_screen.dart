import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
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
import 'package:holdem/utils/app_theme.dart';
import 'package:holdem/utils/event_bus_util.dart';
import 'package:holdem/utils/toast_utils.dart';
import 'package:holdem/utils/track_utils.dart';
import 'package:holdem/widget/common_app_bar.dart';
import 'package:holdem/widget/dialog_common.dart';
import 'package:holdem/widget/dialog_delete_account.dart';
import 'package:holdem/widget/dialog_edit_email.dart';
import 'package:holdem/widget/dialog_edit_nickname.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../model/user.dart';
import '../../routes/app_pages.dart';
import '../../services/index.dart';
import '../../stores/config_store.dart';
import '../../stores/user_store.dart';
import '../../utils/net_request.dart';
import '../../widget/dialog_edit_mobile.dart';
import '../../widget/dialog_edit_username.dart';
import '../../widget/dialog_new_tip.dart';
import 'package:holdem/extensions/num_extensions.dart';
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
        return Stack(
          children: [
            Image.asset(
              Assets.images.mineHeaderBg.path,
              width: 1.sw,
              fit: BoxFit.fitWidth,
            ),
            Scaffold(
              appBar: CommonAppBar.arrowBack(context, title: '个人资料'),
              backgroundColor: Colors.transparent,
              body: Obx(
                    () {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 60.w,
                        margin: EdgeInsets.symmetric(horizontal: 16.w),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                GestureDetector(
                                  onTap: controller.selectImage,
                                  child: SizedBox(
                                    width: 48.w,
                                    height: 48.w,
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
                                ),
                                Positioned(
                                    left: (48.w - 16.w)/2,
                                    bottom: 0,
                                    child: GestureDetector(
                                      onTap: controller.selectImage,
                                      child: Image.asset(
                                        Assets.images.icMineCamera.path,
                                        width: 16.w,
                                      ),
                                    )
                                )
                              ],
                            ),
                            SizedBox(width: 8.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      constraints: BoxConstraints(
                                          maxWidth: 1.sw - 32.w - 48.w - 60.w - 24.w
                                      ),
                                      child: Text(
                                        UserStore.of.user?.nickname ?? '',
                                        maxLines: 2,
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.color_333333,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      width: 84.w,
                                      height: 22.w,
                                      margin: EdgeInsets.only(left: 6.w),
                                      alignment: Alignment.center,
                                      padding:
                                      EdgeInsets.symmetric(horizontal: 2.w),
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: AssetImage(Assets
                                                  .images.iconMineSignBg.path),
                                              fit: BoxFit.fill)),
                                      child: AutoSizeText(
                                        UserStore.of.user?.userLevel?.name ??
                                            '',
                                        maxLines: 1,
                                        minFontSize: 8,
                                        style: TextStyle(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: 3.w),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Get.toNamed(Routes.following,
                                            arguments: true);
                                        TrackUtils.trackEvent(
                                            userLogType: '113004');
                                      },
                                      child: Text(
                                        '关注 ${UserStore.of.user?.followedCount.abbreviateNumber ?? '0'}',
                                        style: TextStyle(
                                          color: AppTheme.color_666666,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    GestureDetector(
                                      onTap: () {
                                        Get.toNamed(Routes.following,
                                            arguments: false);
                                        TrackUtils.trackEvent(
                                            userLogType: '113005');
                                      },
                                      child: Text(
                                        '粉丝 ${UserStore.of.user?.fansCount.abbreviateNumber ?? '0'}',
                                        style: TextStyle(
                                          color: AppTheme.color_666666,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(12.w).copyWith(top: 0),
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
                                          Get.toNamed(Routes.reviseName);
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
                                          Get.toNamed(Routes.reviseAccount);
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
                                          Get.toNamed(Routes.reviseEmail);
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
                                          Get.toNamed(Routes.revisePhone);
                                        },
                                      ),
                                      Obx(
                                            () {
                                          if (ConfigStore.of.isOutsideTheWall.isFalse) {
                                            return const SizedBox();
                                          }
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
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
                                                onTap: TrackUtils.trackedTap(
                                                  onTap: () {
                                                    if (UserStore.of.user?.googleAccount?.isNotEmpty == true) return;
                                                    controller.signInWithGoogle(context);
                                                  },
                                                  userLogType: '115006',
                                                  params: '谷歌',
                                                ),
                                                isBind: UserStore.of.user?.googleAccount?.isNotEmpty == true,
                                              ),
                                              Container(
                                                color: const Color(0xffe6e6e6),
                                                height: 0.5.w,
                                              ),
                                              _buildRowButtonItem(
                                                genImage: Assets.images.iconApple,
                                                label: 'Apple',
                                                onTap: TrackUtils.trackedTap(
                                                  onTap: () {
                                                    if (UserStore.of.user?.appleAccount?.isNotEmpty == true) return;
                                                    controller.signInWithApple(context);
                                                  },
                                                  userLogType: '115006',
                                                  params: '苹果',
                                                ),
                                                isBind: UserStore.of.user?.appleAccount?.isNotEmpty == true,
                                              ),
                                              Container(
                                                color: const Color(0xffe6e6e6),
                                                height: 0.5.w,
                                              ),
                                              _buildRowButtonItem(
                                                genImage: Assets.images.iconTelegram,
                                                label: 'Telegram',
                                                onTap: TrackUtils.trackedTap(
                                                  onTap: () {
                                                    if (UserStore.of.user?.telegramAccount?.isNotEmpty == true) return;
                                                    controller.signInWithTelegram(context);
                                                  },
                                                  userLogType: '115006',
                                                  params: 'TG',
                                                ),
                                                isBind: UserStore.of.user?.telegramAccount?.isNotEmpty == true,
                                              ),
                                              Container(
                                                color: const Color(0xffe6e6e6),
                                                height: 0.5.w,
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 16.w),
                              GestureDetector(
                                onTap: () {
                                  controller.loginOut(context);
                                },
                                behavior: HitTestBehavior.translucent,
                                child: Text(
                                  '注销账号',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppTheme.color_999999,
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
            )
          ],
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
                color: AppTheme.color_666666,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  color: AppTheme.color_333333,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600
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
                  color: isBind ? '#333333'.hexColor.withOpacity(0.1) : AppTheme.color_557BF6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
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
