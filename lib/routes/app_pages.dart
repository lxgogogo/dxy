import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:holdem/page/forget_password/forget_password_screen.dart';
import 'package:holdem/page/forum/page_forum_post_detail.dart';
import 'package:holdem/page/home/home_screen.dart';
import 'package:holdem/page/index/article_detail_page.dart';
import 'package:holdem/page/index/page_book_detail.dart';
import 'package:holdem/page/index/page_video_detail.dart';
import 'package:holdem/page/index/page_video_list.dart';
import 'package:holdem/page/main/main_screen.dart';
import 'package:holdem/page/login/login_screen.dart';
import 'package:holdem/page/search/search_screen.dart';
import 'package:holdem/page/splash/splash_screen.dart';

part 'app_routes.dart';

part 'route_observers.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.splash;

  static final pages = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: Routes.forgetPassword,
      page: () => const ForgetPasswordScreen(),
    ),
    GetPage(
      name: Routes.main,
      page: () => const MainScreen(),
    ),
    GetPage(
      name: Routes.search,
      page: () => const SearchScreen(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeScreen(),
    ),
    GetPage(
      name: Routes.bookDetail,
      page: () => BookDetailPage(id: Get.arguments as int),
    ),
    GetPage(
      name: Routes.articleDetail,
      page: () => ArticleDetailPage(id: Get.arguments as int),
    ),
    GetPage(
      name: Routes.videoDetail,
      page: () => VideoDetailPage(id: Get.arguments as int),
    ),
    GetPage(
      name: Routes.videoList,
      page: () => VideoListPage(id: Get.arguments as int),
    ),
    GetPage(
      name: Routes.postDetail,
      page: () => PostDetailPage(id: Get.arguments as int),
    ),
  ];
}
