import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:get/get.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'i18n/d_pokers_i18n.dart';
import 'utils/env.dart';
import 'utils/pre_config.dart';

void main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  // await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  // 从环境变量中获取环境配置
  const env = String.fromEnvironment('ENV', defaultValue: 'test');
  const platformType = String.fromEnvironment('PLATFORM_TYPE');
  initEnv(env);
  initPlatformType(platformType);

  PreConfig.init().then((value) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      useInheritedMediaQuery: true,
      builder: (context, child) {
        return RefreshConfiguration(
          headerBuilder: () => const ClassicHeader(),
          footerBuilder: () => CustomFooter(
            builder: (context, mode) {
              Widget body;
              TextStyle style = TextStyle(color: Colors.grey, fontSize: 10.sp);
              if (mode == LoadStatus.idle) {
                body = Text('加载更多', style: style);
              } else if (mode == LoadStatus.loading) {
                body = const CupertinoActivityIndicator();
              } else if (mode == LoadStatus.failed) {
                body = Text(
                  '再试一次',
                  style: style,
                );
              } else if (mode == LoadStatus.canLoading) {
                body = Text(
                  '加载更多',
                  style: style,
                );
              } else {
                body = Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 20.w, height: 0.5.w, color: Colors.grey),
                    Text(
                      ' 已经到底啦 ',
                      style: style,
                    ),
                    Container(width: 20.w, height: 0.5.w, color: Colors.grey),
                  ],
                );
              }
              final navBarDistance = kBottomNavigationBarHeight + ScreenUtil().bottomBarHeight;
              return Container(
                height: 50 + navBarDistance,
                padding: EdgeInsets.only(bottom: navBarDistance),
                alignment: Alignment.center,
                child: body,
              );
            },
          ),
          // shouldFooterFollowWhenNotFull: (state) {
          //   // If you want load more with noMoreData state ,may be you should return false
          //   return false;
          // },
          child: GetMaterialApp(
            title: '德学院',
            debugShowCheckedModeBanner: false,
            navigatorObservers: [
              FlutterSmartDialog.observer,
              Routes.observer,
            ],
            localizationsDelegates: const [
              RefreshLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              FlutterQuillLocalizations.delegate,
            ],
            translations: DPokersI18n(),
            supportedLocales: DPokersI18n.supported,
            localeResolutionCallback: (Locale? locale, Iterable<Locale> supportedLocales) {
              return locale;
            },
            fallbackLocale: DPokersI18n.fallback,
            locale: Get.locale,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: AppTheme.color_008EFF),
              useMaterial3: true,
              visualDensity: VisualDensity.compact,
              focusColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hintColor: Colors.transparent,
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
            ),
            builder: FlutterSmartDialog.init(
              builder: (BuildContext context, Widget? child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
                  child: ScrollConfiguration(
                    behavior: NoShadowScrollBehavior(),
                    child: child ?? const Material(),
                  ),
                );
              },
            ),
            initialRoute: AppPages.initial,
            getPages: AppPages.pages,
          ),
        );
      },
    );
  }
}

class NoShadowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    switch (getPlatform(context)) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return child;
      case TargetPlatform.android:
        return GlowingOverscrollIndicator(
          showLeading: false,
          showTrailing: false,
          axisDirection: details.direction,
          color: Colors.transparent,
          child: child,
        );
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return GlowingOverscrollIndicator(
          showLeading: false,
          showTrailing: false,
          axisDirection: details.direction,
          color: Colors.transparent,
          child: child,
        );
    }
  }
}
