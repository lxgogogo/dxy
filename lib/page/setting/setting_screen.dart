import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/stores/storage.dart';
import 'package:holdem/stores/user_store.dart';
import 'package:holdem/widget/dialog_common.dart';
import 'package:holdem/widget/dialog_edit_password.dart';
import 'package:holdem/page/mine/login_helper.dart';
import 'package:holdem/utils/common_utils.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/toast_utils.dart';
import 'package:holdem/widget/background_container.dart';
import 'package:holdem/widget/linear_card.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/app_version.dart';
import '../../utils/app_theme.dart';
import '../../utils/eventbus/EventBusAction.dart';
import '../../utils/eventbus/EventBusManager.dart';
import '../../utils/size_fit.dart';

part 'setting_controller.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
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
      final latestVersion = (CommonUtils.isAndroid(context) ? appVersion.androidVersion : appVersion.iosVersion) ?? '';
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
            width: 22.w,
            height: 22.w,
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
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: LinearCard(
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
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    height: 56.w,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
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
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 12.w),
                  color: AppTheme.color_1A000000,
                  height: 0.5.w,
                ),
                GestureDetector(
                    onTap: () {
                      _checkAppVersion();
                    },
                    behavior: HitTestBehavior.translucent,
                    child: Container(
                      height: 56.w,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
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
                                  width: 7.w,
                                  height: 7.w,
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
        ),
        SizedBox(height: 8.w),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: LinearCard(
            child: Container(
              height: 56.w,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
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
          ),
        ),
        SizedBox(height: 16.w),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: GestureDetector(
            onTap: logout,
            child: Container(
              height: 45.w,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage('assets/images/logout_btn.png'), fit: BoxFit.fill),
              ),
              child: Text(
                '退出登录',
                style: TextStyle(color: const Color(0xff249CFC), fontSize: 15.sp),
              ),
            ),
          ),
        ),
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
        padding: EdgeInsets.all(10.w),
        child: Image.asset(
          asset,
          width: 24.w,
          height: 24.w,
        ),
      ),
    );
  }

  void _checkAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;

    NetRequest().appVersion((data) {
      AppVersion appVersion = AppVersion.fromJson(data);
      String latestVersion = (CommonUtils.isAndroid(context) ? appVersion.androidVersion : appVersion.iosVersion) ?? '';
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
      UserStore.of.clearUserStorage();
      Get.until((route) => route.settings.name == Routes.main);
      //通知首页tab回到主页
      EventBusManager.eventBus.fire(EventBusAction.noticeMainTabSwitchHome.eventBusTypeName);
    });
  }
}
