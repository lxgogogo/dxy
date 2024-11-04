import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:holdem/model/upload_file.dart';
import 'package:holdem/page/mine/page_edit_information.dart';
import 'package:holdem/view/background_container.dart';
import 'package:holdem/view/forum/ToastUtils.dart';
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
  var userName;
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
          userName = _userProfile.nickname;
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
      body: SafeArea(
          child: Container(
              // color: Colors.red,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF4F7FC), Color(0xFFE4EEF9), Color(0xFFE4EEF9)],
              )),
              child: contentView())),
    ));
  }

  Widget contentView() {
    return Column(
      children: [
        SizedBox(
          height: 30.px,
        ),
        Center(
          child: Container(
            width: 70.px,
            height: 70.px,
            alignment: Alignment.center,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(35.px), color: Colors.white, boxShadow: [
              BoxShadow(
                color: Color(0xffC3D9EC), // inset 0 1px 2px 1px #FFFFFF
                offset: Offset(0, 3),
                blurRadius: 6,
              ),
            ]),
            child:
                ClipOval(child: LoginHelper().getUserAvatar(netImageUrl.isNotEmpty ? netImageUrl : '', 64.px, 64.px)),
          ),
        ),
        SizedBox(
          height: 15.px,
        ),
        Center(
          child: GestureDetector(
            onTap: () {
              _phoneSelectImage();
            },
            child: Container(
              width: 80.px,
              height: 33.px,
              alignment: Alignment.center,
              padding: EdgeInsets.only(bottom: 5.px),
              decoration: const BoxDecoration(
                  image: DecorationImage(
                image: AssetImage(
                  'assets/images/change_avatar.png',
                ),
                fit: BoxFit.cover,
              )),
              child: Text(
                '更换头像',
                style: TextStyle(color: Colors.white, fontSize: 12.px),
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(16.px, 24.px, 16.px, 0),
          decoration: BoxDecoration(
            color: Color(0xFFF8FBFF), // background: #F8FBFF
            boxShadow: [
              BoxShadow(
                color: Colors.white, // inset 0 1px 2px 1px #FFFFFF
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
              BoxShadow(
                color: Color.fromRGBO(185, 208, 229, 0.64), // inset 0 -1px 2px 0 rgba(185,208,229,0.64)
                offset: Offset(0, -1),
                blurRadius: 2,
              ),
            ],
            borderRadius: BorderRadius.circular(12.0), // border-radius: 12px
          ),
          child: Column(
            children: [
              // GestureDetector(
              //     onTap: () {
              //       kIsWeb ? _webSelectImage() : _phoneSelectImage();
              //       // : showUploadImageOnPopup(context);
              //     },
              //     child: ListTile(
              //       leading: null,
              //       title: Text(
              //         '头像',
              //         style: AppTheme.text333333Size15,
              //       ),
              //       // 中间文本
              //       trailing: ClipOval(
              //           child: LoginHelper().getUserAvatar(
              //               netImageUrl.isNotEmpty ? netImageUrl : '', 45, 45)),
              //       contentPadding: EdgeInsets.fromLTRB(16, 10, 10, 10),
              //     )),
              // Container(
              //     color: AppTheme.color_1A000000,
              //     width: MediaQuery.of(context).size.width,
              //     height: 0.5.px),
              GestureDetector(
                  onTap: () {
                    Get.to(InformationEditPage(editContent: userName));
                  },
                  child: Container(
                      padding: EdgeInsets.only(right: 10.px),
                      margin: EdgeInsets.fromLTRB(0, 16.px, 0, 16.px),
                      child: Row(children: [
                        SizedBox(
                          width: 16.px,
                        ),
                        Text(
                          '昵称',
                          style: AppTheme.text333333Size15,
                        ),
                        SizedBox(
                          width: 10.px,
                        ),
                        Text(
                          _userProfile != null && _userProfile.nickname != null ? _userProfile.nickname! : '',
                          style: TextStyle(color: const Color(0xff9399A5), fontSize: 14.px),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                        const Spacer(),
                        ImageIcon(
                          AssetImage('assets/images/item_arrow.png'),
                          size: 22,
                        )
                      ]))),
              Container(color: AppTheme.color_1A000000, width: MediaQuery.of(context).size.width, height: 0.5.px),
              GestureDetector(
                  onTap: () {},
                  child: Container(
                      padding: EdgeInsets.only(right: 10.px),
                      margin: EdgeInsets.fromLTRB(0, 16.px, 0, 16.px),
                      child: Row(children: [
                        SizedBox(
                          width: 16.px,
                        ),
                        Text(
                          '邮箱',
                          style: AppTheme.text333333Size15,
                        ),
                        SizedBox(
                          width: 10.px,
                        ),
                        Text(
                          _userProfile != null && _userProfile.account != null ? _userProfile.account! : '',
                          style: TextStyle(color: const Color(0xff9399A5), fontSize: 14.px),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                        const Spacer(),
                        ImageIcon(
                          AssetImage('assets/images/item_arrow.png'),
                          size: 22,
                        )
                      ]))
                  // ListTile(
                  //   leading: null,
                  //   title: Text(
                  //     '邮箱',
                  //     style: AppTheme.text333333Size15,
                  //   ),
                  //   // 中间文本
                  //   trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  //     Text(
                  //       _userProfile != null && _userProfile.account != null
                  //           ? _userProfile.account!
                  //           : '',
                  //       style: AppTheme.text666666Size15,
                  //       textAlign: TextAlign.right,
                  //     ),
                  //     ImageIcon(
                  //       AssetImage('assets/images/item_arrow.png'),
                  //       size: 22,
                  //     )
                  //   ]),
                  //   contentPadding: EdgeInsets.fromLTRB(16, 8, 10, 8),
                  // )
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
