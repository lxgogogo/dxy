import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:get/get.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:audioplayers/audioplayers.dart';
import 'utils/pre_config.dart';
import 'utils/env.dart';



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
          footerBuilder: () => const ClassicFooter(
            noDataText: '—— 已经到底啦 ——',
          ),
          // shouldFooterFollowWhenNotFull: (state) {
          //   // If you want load more with noMoreData state ,may be you should return false
          //   return false;
          // },
          child: OKToast(
            child: GetMaterialApp(
              title: '德学院',
              debugShowCheckedModeBanner: false,
              navigatorObservers: [
                Routes.observer,
              ],
              localizationsDelegates: const [
                RefreshLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                FlutterQuillLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', 'US'),
                Locale('zh', 'CN'),
              ],
              localeResolutionCallback: (locale, Iterable<Locale> supportedLocales) {
                return locale;
              },
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: AppTheme.color_008EFF),
                useMaterial3: true,
                visualDensity: VisualDensity.compact,
                focusColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hintColor: Colors.transparent,
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                appBarTheme: AppBarTheme(
                  scrolledUnderElevation: 0.0,
                  titleTextStyle: TextStyle(
                    fontSize: 16.sp,
                    color: Color(0xff2C2C2C),
                  ),
                ),
                // 设置最大宽度为 960px
                // 可根据需求调整该值
              ),
              // home: WebFitPage(child: SplashScreen()),
              builder: EasyLoading.init(
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
