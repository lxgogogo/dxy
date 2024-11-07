import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_splash_screen/flutter_splash_screen.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:get/get.dart';
import 'package:holdem/page/forum/page_forum_post_detail.dart';
import 'package:holdem/page/index/article_detail_page.dart';
import 'package:holdem/page/index/page_book_detail.dart';
import 'package:holdem/page/index/page_video_detail.dart';
import 'package:holdem/page/index/page_video_list.dart';
import 'package:holdem/page/main_page.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:holdem/utils/common_utils.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'utils/pre_config.dart';

void main() {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  PreConfig.init().then((value) {
    runApp(const MyApp());
  });
}

///hide your splash screen
Future<void> hideScreen() async {
  Future.delayed(const Duration(milliseconds: 2000), () {
    FlutterSplashScreen.hide();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (CommonUtils.isAndroid(context)) {
      hideScreen();
    }
    // EasyLoading.init();
    return OKToast(
        child: GetMaterialApp(
      title: '德学院',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        RefreshLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
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
        appBarTheme: const AppBarTheme(
          scrolledUnderElevation: 0.0,
          titleTextStyle: TextStyle(
            fontSize: 16,
            color: Color(0xff2C2C2C),
          ),
        ),
        // 设置最大宽度为 960px
        // 可根据需求调整该值
      ),
      // home: WebFitPage(child: SplashScreen()),
      builder: EasyLoading.init(),
      initialRoute: '/',
      routes: {
        // '/': (context) => MainScreen(),
        '/': (context) => MainScreen(),
        '/book_detail': (context) => BookDetailPage(
            id: int.parse(
                ModalRoute.of(context)!.settings.arguments.toString())),
        '/article_detail': (context) => ArticleDetailPage(
            id: int.parse(
                ModalRoute.of(context)!.settings.arguments.toString())),
        '/video_detail': (context) => VideoDetailPage(
            id: int.parse(
                ModalRoute.of(context)!.settings.arguments.toString())),
        '/video_list': (context) => VideoListPage(
            id: int.parse(
                ModalRoute.of(context)!.settings.arguments.toString())),
        '/post_detail': (context) => PostDetailPage(
            postId: int.parse(
                ModalRoute.of(context)!.settings.arguments.toString())),
      },
      onGenerateRoute: (settings) {
        final Uri uri = Uri.parse(settings.name!);
        final String path = uri.path;
        final Map<String, String> parameters = uri.queryParameters;

        switch (path) {
          case '/book_detail':
            return MaterialPageRoute(
              builder: (context) =>
                  BookDetailPage(id: int.parse(parameters['id']!)),
            );
          case '/article_detail':
            return MaterialPageRoute(
              builder: (context) =>
                  ArticleDetailPage(id: int.parse(parameters['id']!)),
            );
          case '/video_detail':
            return MaterialPageRoute(
              builder: (context) =>
                  VideoDetailPage(id: int.parse(parameters['id']!)),
            );
          case '/video_list':
            return MaterialPageRoute(
              builder: (context) =>
                  VideoListPage(id: int.parse(parameters['id']!)),
            );
          case '/post_detail':
            return MaterialPageRoute(
              builder: (context) =>
                  PostDetailPage(postId: int.parse(parameters['postId']!)),
            );
        }
      },
    ));
  }
}
