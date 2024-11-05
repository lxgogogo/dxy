import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:holdem/model/upload_file.dart';
import 'package:holdem/page/mine/dialog_edit_email.dart';
import 'package:holdem/page/mine/dialog_edit_nickname.dart';
import 'package:holdem/view/background_container.dart';
import 'package:holdem/view/forum/ToastUtils.dart';
import 'package:holdem/widget/linear_card.dart';
import 'package:image_picker/image_picker.dart';

import '../../model/user.dart';
import '../../utils/app_theme.dart';
import '../../utils/eventbus/EventBusAction.dart';
import '../../utils/eventbus/EventBusManager.dart';
import '../../utils/net_request.dart';
import '../../utils/size_fit.dart';
import '../../widget/page_web_fit.dart';
import 'login_helper.dart';

class PersonalPage extends StatefulWidget {
  PersonalPage({Key? key}) : super(key: key);

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  String imageUrl = ""; //本地图片地址
  var netImageUrl = ""; //服务器接口获取到的图片地址
  ImageProvider? avatar = const AssetImage("assets/images/default_avatar.png");
  late UserProfile _userProfile;
  bool _isMounted = false;
  var actionEventBus;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isMounted = true;
    _userProfile = UserProfile();
    getUserInfo();
    //接受通知刷新页面
    actionEventBus = EventBusManager.eventBus.on().listen((event) {
      if (event.toString() == EventBusAction.refreshPersonalProfile.eventBusTypeName) {
        getUserInfo();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _isMounted = false;
  }

  void getUserInfo() {
    EasyLoading.show(status: 'loading...');
    LoginHelper().getUserInfo((data) {
      EasyLoading.dismiss();
      if (_isMounted) {
        setState(() {
          _userProfile = data;
          netImageUrl = _userProfile.avatar!;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
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
          '个人资料',
          style: AppTheme.text333333Size17,
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.transparent,
      body: contentView(),
    ));
  }

  Widget contentView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 23.5.px,
        ),
        Center(
          child: Container(
            width: 69.px,
            height: 69.px,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(69.px),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff6d85b5).withOpacity(0.16), // inset 0 1px 2px 1px #FFFFFF
                  offset: Offset(0, 3.px),
                  blurRadius: 4.px,
                ),
              ],
            ),
            child: ClipOval(
              child: LoginHelper().getUserAvatar(
                netImageUrl.isNotEmpty ? netImageUrl : '',
                63.px,
                63.px,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 12.px,
        ),
        Center(
          child: GestureDetector(
            onTap: () {
              _phoneSelectImage();
            },
            child: Container(
              width: 72.px,
              padding: EdgeInsets.only(top: 4.4.px, bottom: 6.2.px),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/change_avatar.png',
                  ),
                  fit: BoxFit.fill,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '更换头像',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.px,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        LinearCard(
          margin: EdgeInsets.fromLTRB(16.px, 24.px, 16.px, 0),
          padding: EdgeInsets.symmetric(horizontal: 19.px),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  showDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (context) => DialogEditNickname(
                      editContent: _userProfile.nickname ?? '',
                    ),
                  );
                },
                child: Container(
                  height: 48.5.px,
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      Text(
                        '昵称',
                        style: TextStyle(
                          fontSize: 14.px,
                          color: const Color(0xff2a2a2a),
                        ),
                      ),
                      SizedBox(width: 14.px),
                      Expanded(
                        child: Text(
                          _userProfile.nickname ?? '',
                          style: TextStyle(
                            color: const Color(0xff9399A5),
                            fontSize: 14.px,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Image.asset('assets/images/item_arrow.png', width: 24.px),
                    ],
                  ),
                ),
              ),
              Container(
                color: const Color(0xffe6e6e6),
                height: 0.5.px,
              ),
              GestureDetector(
                onTap: () {
                  showDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (context) => DialogEditEmail(
                      editContent: _userProfile.account ?? '',
                    ),
                  );
                },
                child: Container(
                  height: 48.5.px,
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      Text(
                        '邮箱',
                        style: TextStyle(
                          fontSize: 14.px,
                          color: const Color(0xff2a2a2a),
                        ),
                      ),
                      SizedBox(width: 14.px),
                      Expanded(
                        child: Text(
                          _userProfile.account ?? '',
                          style: TextStyle(
                            color: const Color(0xff9399A5),
                            fontSize: 14.px,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Image.asset('assets/images/item_arrow.png', width: 24.px),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _phoneSelectImage() async {
    final ImagePicker picker = ImagePicker();
    var picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      imageQuality: 40,
    );

    if (picked != null) {
      imageUrl = picked.path;
    }
    if (imageUrl.isNotEmpty) {
      NetRequest().updateAvatar(imageUrl, (data) {
        ToastUtils.showToast('上传成功');
        EventBusManager.eventBus.fire(EventBusAction.refreshPersonalProfile.eventBusTypeName);
      }, (errMsg) {
        ToastUtils.showToast('上传文件失败，请重新上传');
      }, (int sent, int total) {});
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
            height: 200.px, // 设置弹窗高度
            child: Column(
              children: [
                Expanded(
                  child: Container(), // 占位组件，用于将内容推至底部之上
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 52.px,
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
                        height: 52.px,
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
                      height: 82.px,
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
