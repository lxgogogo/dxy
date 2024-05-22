import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/page/mine/page_edit_information.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../model/upload_file.dart';
import '../../model/user.dart';
import '../../utils/app_theme.dart';
import '../../utils/eventbus/EventBusAction.dart';
import '../../utils/eventbus/EventBusManager.dart';
import '../../utils/net_request.dart';
import '../../utils/size_fit.dart';
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
      if (event.toString() ==
          EventBusAction.refreshPersonalProfile.eventBusTypeName) {
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
    LoginHelper().getUserInfo((data) {
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
    return Scaffold(
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
        backgroundColor: AppTheme.color_F3F3F3,
        title: const Text(
          '个人资料',
          style: AppTheme.text333333Size17,
        ),
        centerTitle: true,
      ),
      body: SafeArea(child: contentView()),
      backgroundColor: AppTheme.color_F3F3F3,
    );
  }

  Widget contentView() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(16.px, 0, 16.px, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              GestureDetector(
                  onTap: () {
                    kIsWeb
                        ? _webSelectImage()
                        : showUploadImageOnPopup(context);
                  },
                  child: ListTile(
                    leading: null,
                    title: Text(
                      '头像',
                      style: AppTheme.text333333Size15,
                    ),
                    // 中间文本
                    trailing: ClipOval(
                        child: LoginHelper().getUserAvatar(
                            netImageUrl.isNotEmpty ? netImageUrl : '', 45, 45)),
                    contentPadding: EdgeInsets.fromLTRB(16, 10, 10, 10),
                  )),
              Container(
                  color: AppTheme.color_1A000000,
                  width: MediaQuery.of(context).size.width,
                  height: 0.5.px),
              GestureDetector(
                  onTap: () {
                    Get.to(InformationEditPage(editContent: userName));
                  },
                  child: ListTile(
                    leading: null,
                    title: Text(
                      '昵称',
                      style: AppTheme.text333333Size15,
                    ),
                    // 中间文本
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(
                        _userProfile != null && _userProfile.nickname != null
                            ? _userProfile.nickname!
                            : '',
                        style: AppTheme.text666666Size15,
                      ),
                      ImageIcon(
                        AssetImage('assets/images/item_arrow.png'),
                        size: 22,
                      )
                    ]),
                    contentPadding: EdgeInsets.fromLTRB(16, 0, 10, 0),
                  )),
              Container(
                  color: AppTheme.color_1A000000,
                  width: MediaQuery.of(context).size.width,
                  height: 0.5.px),
              GestureDetector(
                  onTap: () {},
                  child: ListTile(
                    leading: null,
                    title: Text(
                      '邮箱',
                      style: AppTheme.text333333Size15,
                    ),
                    // 中间文本
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(
                        _userProfile != null && _userProfile.account != null
                            ? _userProfile.account!
                            : '',
                        style: AppTheme.text666666Size15,
                      ),
                      ImageIcon(
                        AssetImage('assets/images/item_arrow.png'),
                        size: 22,
                      )
                    ]),
                    contentPadding: EdgeInsets.fromLTRB(16, 0, 10, 0),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  _webSelectImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.image);
    if (result != null) {
      var files = result.files;
      print('FilePickerResult=============:' + files.first.name);
      NetRequest().updateAvatarBytesFile(files.first, (data) {

        // UploadFile uploadFile = UploadFile.fromJson(data);
        // setState(() {
        //   netImageUrl = uploadFile.url!;
        // });
        // print('FilePickerResult url============' + uploadFile.url!);
        //通知个人信息页面刷新
        EventBusManager.eventBus
            .fire(EventBusAction.refreshPersonalProfile.eventBusTypeName);
      });
    }
  }

  _phoneSelectImage() async {
    late PermissionStatus status;
    if (Platform.isIOS) {
      status = await Permission.photos.request();
      if (status == PermissionStatus.permanentlyDenied) {
        showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              content: const Text(
                "请点击 跳转至设置界面, 打开照片权限, 设置权限成功后再次上传头像",
                style: AppTheme.text333333Size15,
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: const Text(
                    "取消",
                    style: AppTheme.text333333Size15,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                CupertinoDialogAction(
                  child: const Text(
                    "跳转至设置界面",
                    style: AppTheme.text333333Size15,
                  ),
                  onPressed: () {
                    openAppSettings();
                  },
                ),
              ],
            );
          },
        );
      } else {
        final ImagePicker _picker = ImagePicker();
        // Pick an image
        var picked = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 400,
          imageQuality: 60,
        );

        if (picked != null) {
          // setState(() {
          imageUrl = picked.path;
          // avatar = (kIsWeb
          //     ? NetworkImage(picked.path)
          //     : FileImage(File(
          //   picked.path,
          // ))) as ImageProvider;
          // });
        }
      }
    } else {
      final ImagePicker picker = ImagePicker();
      // Pick an image
      var picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        imageQuality: 60,
      );

      if (picked != null) {
        imageUrl = picked.path;
      }
    }

    //
    print("imageUrl===>$imageUrl");
    if (imageUrl.isNotEmpty) {
      _updateAvatar(imageUrl);
      // UserRequestManger.uploadFile(
      //     UserRequestManger.UPLOAD_FILE_TYPE_IMAGE, imageUrl, (data) {
      //   Navigator.of(context).pop(); //关闭弹窗
      //   setState(() {
      //     avatar = (kIsWeb
      //         ? NetworkImage(imageUrl)
      //         : FileImage(File(
      //       imageUrl,
      //     ))) as ImageProvider;
      //   });
      // }, (errorMsg) {
      //   Navigator.of(context).pop(); //关闭弹窗
      //   Fluttertoast.showToast(msg: errorMsg);
      // });
    }
  }

  Future<void> _takePicture() async {
    final imagePicker = ImagePicker();
    final XFile? image =
        await imagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      if (image != null) {
        File? _image = File(image.path);
        imageUrl = image.path;
        print("imageUrl===>$imageUrl");
      }
    });
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

  void _updateAvatar(String filePath) {
    NetRequest().updateAvatar(filePath, (data) {
      // getUserInfo();
      //通知个人信息页面刷新
      EventBusManager.eventBus
          .fire(EventBusAction.refreshPersonalProfile.eventBusTypeName);
    });
  }
}
