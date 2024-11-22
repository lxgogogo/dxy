import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/main.dart';
import 'package:holdem/page/mine/dialog_common.dart';
import 'package:holdem/page/mine/dialog_edit_password.dart';
import 'package:holdem/page/mine/login_helper.dart';
import 'package:holdem/page/mine/page_register_account.dart';
import 'package:holdem/utils/common_utils.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/view/background_container.dart';
import 'package:holdem/view/forum/ToastUtils.dart';
import 'package:holdem/widget/button.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/app_version.dart';
import '../../utils/app_theme.dart';
import '../../utils/eventbus/EventBusAction.dart';
import '../../utils/eventbus/EventBusManager.dart';
import '../../utils/size_fit.dart';
import '../../widget/page_web_fit.dart';
import 'package:universal_html/html.dart' as html;

class SettingsPage extends StatefulWidget {
  SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _currentVersion = '';
  bool _canUpdate = false;

  @override
  void initState() {
    super.initState();
    _requestAppInfo();
  }

  Future<void> _requestAppInfo() async {
    final res = await PackageInfo.fromPlatform();
    _currentVersion = res.version;
    NetRequest().appVersion((data) {
      final appVersion = AppVersion.fromJson(data);
      final latestVersion = appVersion.androidVersion ?? '';
      _canUpdate = latestVersion.compareTo(_currentVersion) > 0;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
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
          '设置',
          style: AppTheme.text333333Size17,
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.transparent,
      body: SafeArea(child: contentView()),
    ));
  }

  Widget contentView() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(16.px, 0, 16.px, 0),
          decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage('assets/images/setting_bg.png'), fit: BoxFit.fill)),
          child: Column(
            children: [
              GestureDetector(
                  onTap: () {
                    showDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (context) => const DialogEditPassword(),
                    );
                  },
                  child: Container(
                    height: 56.px,
                    padding: EdgeInsets.symmetric(horizontal: 17.px),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '修改密码',
                          style: AppTheme.text333333Size15,
                        ),
                        ImageIcon(
                          AssetImage('assets/images/item_arrow.png'),
                          size: 22,
                        )
                      ],
                    ),
                  )),
              Container(
                color: AppTheme.color_1A000000,
                height: 0.5.px,
              ),
              GestureDetector(
                  onTap: () {
                    _checkAppVersion();
                  },
                  child: Container(
                    height: 56.px,
                    padding: EdgeInsets.symmetric(horizontal: 17.px),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '检查更新',
                          style: AppTheme.text333333Size15,
                        ),
                        Row(
                          children: [
                            Text(
                              '当前版本 $_currentVersion${_canUpdate ? ' (可更新) ' : ''}',
                              style: AppTheme.text333333Size15,
                            ),
                            if (_canUpdate)
                              Container(
                                width: 7.px,
                                height: 7.px,
                                decoration: const ShapeDecoration(shape: CircleBorder(), color: Color(0xffff4040)),
                              ),
                            const ImageIcon(
                              AssetImage('assets/images/item_arrow.png'),
                              size: 22,
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(16.px, 0, 16.px, 0),
          decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage('assets/images/setting_bg.png'), fit: BoxFit.fill)),
          child: Column(
            children: [
              Container(
                height: 56.px,
                padding: EdgeInsets.symmetric(horizontal: 17.px),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '社群',
                      style: AppTheme.text333333Size15,
                    ),
                    const Spacer(),
                    buildSocialIcon(
                      'assets/images/ic_facebook.png',
                      url: 'https://www.facebook.com/dexueyuan/?locale=zh_TW',
                    ),
                    buildSocialIcon(
                      'assets/images/ic_twitter.png',
                      url: 'https://x.com/dpoker_club?s=21&t=u-3l2w44NuA9Tu0UcJ-jdQ',
                    ),
                    buildSocialIcon(
                      'assets/images/ic_tiktok.png',
                      url: 'https://www.tiktok.com/@dexueyuan?_t=8qAwlHWfhnl&_r=1',
                    ),
                    buildSocialIcon(
                      'assets/images/ic_telegram.png',
                      url: 'https://t.me/dpoker',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
            margin: EdgeInsets.fromLTRB(16.px, 20.px, 16.px, 0),
            decoration: BoxDecoration(
              color: Colors.transparent, // 设置白色背景色
              borderRadius: BorderRadius.circular(10), // 添加圆角
            ),
            child: GestureDetector(
              onTap: () {
                logout();
              },
              child: Container(
                width: 350.px,
                height: 45.px,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    image: DecorationImage(image: AssetImage('assets/images/logout_btn.png'), fit: BoxFit.fill)),
                child: Text(
                  '退出登录',
                  style: TextStyle(color: const Color(0xff249CFC), fontSize: 15.px),
                ),
              ),
              // child: const ListTile(
              //   leading: ImageIcon(
              //     AssetImage('assets/images/logout.png'),
              //     size: 22,
              //   ),
              //   title: Text(
              //     '退出登录',
              //     style: AppTheme.text333333Size15,
              //   ),
              //   // 中间文本
              //   trailing: ImageIcon(
              //     AssetImage('assets/images/item_arrow.png'),
              //     size: 22,
              //   ),
              //   contentPadding: EdgeInsets.fromLTRB(16, 0, 10, 0),
              // ),
            )),
      ],
    );
  }

  Widget buildSocialIcon(
    String asset, {
    required String url,
  }) {
    return GestureDetector(
      onTap: () {
        launchUrl(Uri.parse(url));
      },
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: EdgeInsets.all(10.px),
        child: Image.asset(
          asset,
          width: 24.px,
          height: 24.px,
        ),
      ),
    );
  }

  void _checkAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;

    NetRequest().appVersion((data) {
      AppVersion appVersion = AppVersion.fromJson(data);
      String latestVersion = appVersion.androidVersion ?? '';
      if (latestVersion.isNotEmpty == true) {
        if (latestVersion.compareTo(currentVersion) > 0) {
          // 强制升级
          bool forceUpdate = appVersion.forced ?? false;
          if (forceUpdate) {
            // 这里可以弹出不可取消的弹窗提示用户升级
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => CommonDialog(
                title: '更新以获得最佳体验',
                onConfirm: () {
                  _launchURL(appVersion);
                },
                onlyConfirm: true,
              ),
            );
          } else {
            // 普通升级
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => CommonDialog(
                title: '有新版本可以更新',
                confirmText: '立即更新',
                onConfirm: () {
                  Navigator.of(context).pop();
                  _launchURL(appVersion);
                },
                cancelText: '下次再说',
              ),
            );
          }
        } else {
          ToastUtils.showToast('当前已经是最新版本');
        }
      } else {
        ToastUtils.showToast('当前已经是最新版本');
      }
    });
  }

  _launchURL(AppVersion appVersion) async {
    var url = '';
    if (CommonUtils.isAndroid(context)) {
      url = appVersion.androidUrl!;
    } else {
      url = appVersion.iosUrl!;
    }
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  void logout() {
    NetRequest().logout((data) {
      LoginHelper().clearGlobalUserInfo();
      //回到首页
      Navigator.of(context).pop();
      //通知首页tab回到主页
      EventBusManager.eventBus.fire(EventBusAction.noticeMainTabSwitchHome.eventBusTypeName);
    });
  }
}
