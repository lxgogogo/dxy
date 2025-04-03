import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/utils/toast_utils.dart';
import 'package:holdem/widget/dialog_delete_account.dart';
import 'package:holdem/widget/dialog_edit_account.dart';
import 'package:holdem/widget/dialog_edit_email.dart';
import 'package:holdem/widget/dialog_edit_nickname.dart';
import 'package:image_picker/image_picker.dart';

import '../../stores/user_store.dart';
import '../../utils/app_theme.dart';
import '../../utils/net_request.dart';
import '../../utils/size_fit.dart';
import '../../widget/dialog_edit_mobile.dart';

part 'personal_controller.dart';

class PersonalScreen extends StatefulWidget {
  const PersonalScreen({Key? key}) : super(key: key);

  @override
  State<PersonalScreen> createState() => _PersonalScreenState();
}

class _PersonalScreenState extends State<PersonalScreen> {
  String imageUrl = ""; //本地图片地址
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    UserStore.of.getUserInfo();
  }

  @override
  void dispose() {
    super.dispose();
    _isMounted = false;
  }

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset(
            'assets/images/back.png',
            width: 22.w,
            height: 22.w,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        title: const Text(
          '个人资料',
          style: AppTheme.text333333Size17,
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: contentView(),
    );
  }

  Widget contentView() {
    return Obx(() {
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
                index: imageUrl.isNotEmpty ? 0 : 1,

                /// 保留新netImage渲染,返回后也能加快加载
                sizing: StackFit.expand,
                children: [
                  Image.file(
                    File(imageUrl),
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
            onTap: _phoneSelectImage,
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
          Container(
            padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.w),
            child: Column(
              children: [
                _buildRowItem(
                  label: '昵称',
                  value: UserStore.of.user?.nickname ?? '',
                  onTap: () {
                    showDialog(
                      barrierDismissible: true,
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
                  value: UserStore.of.user?.account ?? '',
                  onTap: () {
                    showDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (context) => DialogEditAccount(
                        editContent: UserStore.of.user?.account ?? '',
                      ),
                    );
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
                      barrierDismissible: true,
                      context: context,
                      builder: (context) => DialogEditEmail(
                        editContent: UserStore.of.user?.account ?? '',
                      ),
                    );
                  },
                ),
                Container(
                  color: const Color(0xffe6e6e6),
                  height: 0.5.w,
                ),
                _buildRowItem(
                  label: '手机号',
                  value: UserStore.of.user?.account ?? '',
                  onTap: () {
                    showDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (context) => DialogEditMobile(
                        editContent: UserStore.of.user?.account ?? '',
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              showDialog(
                barrierDismissible: true,
                context: context,
                builder: (context) => const DialogDeleteAccount(),
              );
            },
            behavior: HitTestBehavior.translucent,
            child: Container(
              height: 48.5.w,
              alignment: Alignment.center,
              child: Text(
                '注销账号',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.red,
                ),
              ),
            ),
          ),
          SizedBox(height: 26.w)
        ],
      );
    });
  }

  GestureDetector _buildRowItem({
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48.5.w,
        alignment: Alignment.center,
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: '#333333'.hexColor,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(width: 14.w),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  color: '#333333'.hexColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 16.w),
            Image.asset('assets/images/edit_password.png', width: 24.w),
          ],
        ),
      ),
    );
  }

  _phoneSelectImage() async {
    final ImagePicker picker = ImagePicker();
    var picked = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (picked != null) {
      final fileLength = await picked.length();
      if (fileLength > 10 * 1024 * 1024) {
        ToastUtils.showToast('上传头像不得超过10M');
        return;
      }
      imageUrl = picked.path;
      if (imageUrl.isNotEmpty) {
        NetRequest().updateAvatar(imageUrl, (data) {
          ToastUtils.showToast('上传成功');
          final url = data?['url'];
          if (url is String) {
            UserStore.of.updateUserInfo({'avatar': url});
          }
        }, (errMsg) {
          ToastUtils.showToast('上传文件失败，请重新上传');
        }, (int sent, int total) {}).whenComplete(() {});
      }
    }
  }

  Future<void> _takePicture() async {
    final imagePicker = ImagePicker();
    final XFile? image = await imagePicker.pickImage(source: ImageSource.camera);

    if (_isMounted) {
      setState(() {
        if (image != null) {
          File? _image = File(image.path);
          imageUrl = _image.path;
          print("imageUrl===>$imageUrl");
        }
      });
    }
  }

  //上传图片底部弹窗
  void showUploadImageOnPopup(BuildContext context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: AppTheme.white,
        isScrollControlled: true,
        isDismissible: true,
        builder: (BuildContext context) {
          return SizedBox(
            height: 200.w, // 设置弹窗高度
            child: Column(
              children: [
                Expanded(
                  child: Container(), // 占位组件，用于将内容推至底部之上
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 52.w,
                      child: GestureDetector(
                        onTap: () {
                          _takePicture();
                          Navigator.of(context).pop();
                        },
                        child: Center(
                          child: Text(
                            '拍照',
                            style: AppTheme.text333333Size15,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      color: AppTheme.color_F3F3F3,
                      height: 1.0,
                      width: MediaQuery.of(context).size.width, // 宽度与屏幕宽度相同
                    ),
                    SizedBox(
                        height: 52.w,
                        child: Center(
                            child: GestureDetector(
                          onTap: () {
                            _phoneSelectImage();
                            Navigator.of(context).pop();
                          },
                          child: Center(
                            child: Text(
                              '选择图片',
                              style: AppTheme.text333333Size15,
                            ),
                          ),
                        ))),
                    Container(
                      color: AppTheme.color_F3F3F3,
                      height: 8.0,
                      width: MediaQuery.of(context).size.width, // 宽度与屏幕宽度相同
                    ),
                    SizedBox(
                      height: 82.w,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop(); //关闭弹窗
                        },
                        child: Center(
                          child: Text(
                            '取消',
                            style: AppTheme.text999999Size16,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          );
        });
  }
}
