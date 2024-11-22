import 'package:flutter/material.dart';
import 'package:holdem/model/app_version.dart';
import 'package:holdem/page/index/home_page.dart';
import 'package:holdem/page/message/page_message.dart';
import 'package:holdem/page/mine/dialog_common.dart';
import 'package:holdem/utils/common_utils.dart';
import 'package:holdem/utils/global.dart';
import 'package:holdem/utils/net_request.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/view/background_container.dart';
import 'package:holdem/view/forum/ToastUtils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/eventbus/EventBusAction.dart';
import '../utils/eventbus/EventBusManager.dart';
import 'forum/page_forum_tab.dart';
import 'mine/page_mine.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [HomePage(), ForumTabPage(), MessagePage(), MinePage()];

  var actionEventBus;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkAppVersion();
    //接受退出登录之后首页tab通知切换到0位置
    actionEventBus = EventBusManager.eventBus.on().listen((event) {
      if (event.toString() == EventBusAction.noticeMainTabSwitchHome.eventBusTypeName) {
        setState(() {
          _currentIndex = 0;
        });
      }
    });
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

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return BackgroundContainer(
      child: Scaffold(
        body: _pages[_currentIndex],
        backgroundColor: Colors.transparent,
        bottomNavigationBar: Container(
            padding: EdgeInsets.only(top: 12.px),
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff1e0000).withOpacity(0.12),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              selectedItemColor: const Color(0xff008EFF),
              unselectedItemColor: const Color(0xff9CACC9),
              showSelectedLabels: true,
              // 取消显示选中项的标签
              showUnselectedLabels: true,
              // 取消显示未选中项的标签
              useLegacyColorScheme: false,
              onTap: (int index) {
                if ((index == 2 || index == 3)) {
                  Global().checkLogin(() {
                    _currentIndex = index;
                    setState(() {});
                  });
                } else {
                  _currentIndex = index;
                  setState(() {});
                }
              },
              items: [
                BottomNavigationBarItem(
                  icon: Image.asset(
                    _currentIndex == 0 ? 'assets/images/tab_index_sel.png' : 'assets/images/tab_index.png',
                    width: 20.px,
                    height: 20.px,
                  ),
                  label: '首页',
                ),
                BottomNavigationBarItem(
                  icon: Image.asset(
                    _currentIndex == 1 ? 'assets/images/tab_forum_sel.png' : 'assets/images/tab_forum.png',
                    width: 20.px,
                    height: 20.px,
                  ),
                  label: '论坛',
                ),
                BottomNavigationBarItem(
                  icon: Image.asset(
                    _currentIndex == 2 ? 'assets/images/tab_message_sel.png' : 'assets/images/tab_message.png',
                    width: 20.px,
                    height: 20.px,
                  ),
                  label: '消息',
                ),
                BottomNavigationBarItem(
                  icon: Image.asset(
                    _currentIndex == 3 ? 'assets/images/tab_me_sel.png' : 'assets/images/tab_me.png',
                    width: 20.px,
                    height: 20.px,
                  ),
                  label: '我的',
                ),
              ],
            )),
      ),
    );
  }
}
