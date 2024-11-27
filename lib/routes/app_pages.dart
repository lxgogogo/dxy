import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:holdem/model/board_info.dart';
import 'package:holdem/page/at_user/at_user_screen.dart';
import 'package:holdem/page/comment_input/comment_input_screen.dart';
import 'package:holdem/page/comment_list/comment_list_screen.dart';
import 'package:holdem/page/comment_publish/comment_publish_screen.dart';
import 'package:holdem/page/feed_list/feed_list_screen.dart';
import 'package:holdem/page/feed_post/feed_post_screen.dart';
import 'package:holdem/page/following/following_screen.dart';
import 'package:holdem/page/forget_password/forget_password_screen.dart';
import 'package:holdem/page/feed_detail/feed_detail_screen.dart';
import 'package:holdem/page/home/home_screen.dart';
import 'package:holdem/page/article_detail/article_detail_screen.dart';
import 'package:holdem/page/book_detail/book_detail_screen.dart';
import 'package:holdem/page/video_detail/video_detail_screen.dart';
import 'package:holdem/page/video_list/video_list_screen.dart';
import 'package:holdem/page/main/main_screen.dart';
import 'package:holdem/page/login/login_screen.dart';
import 'package:holdem/page/reply_list/reply_list_screen.dart';
import 'package:holdem/page/search/search_screen.dart';
import 'package:holdem/page/setting/setting_screen.dart';
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
      name: Routes.feedList,
      page: () => const FeedListScreen(),
    ),
    GetPage(
      name: Routes.setting,
      page: () => const SettingScreen(),
    ),
    GetPage(
      name: Routes.atUser,
      page: () => const AtUserScreen(),
    ),
    GetPage(
      name: Routes.publishComment,
      page: () {
        final arguments = Get.arguments as Map;
        return CommentPublishScreen(
          relType: arguments['relType'],
          relId: arguments['relId'],
        );
      },
    ),
    GetPage(
      name: Routes.inputComment,
      page: () {
        final arguments = Get.arguments as Map;
        return CommentInputScreen(
          relType: arguments['relType'],
          relId: arguments['relId'],
        );
      },
    ),
    GetPage(
      name: Routes.commentList,
      page: () {
        final arguments = Get.arguments as Map;
        return CommentListScreen(
          relType: arguments['relType'],
          relId: arguments['relId'],
        );
      },
    ),
    GetPage(
      name: Routes.replyList,
      page: () {
        final arguments = Get.arguments as Map;
        return ReplyListScreen(
          id: arguments['id'],
          commentBean: arguments['commentBean'],
        );
      },
    ),
    GetPage(
      name: Routes.following,
      page: () => FollowingScreen(isFollowPage: Get.arguments as bool),
    ),
    GetPage(
      name: Routes.bookDetail,
      page: () => BookDetailScreen(id: Get.arguments as int),
    ),
    GetPage(
      name: Routes.articleDetail,
      page: () => ArticleDetailScreen(id: Get.arguments as int),
    ),
    GetPage(
      name: Routes.videoDetail,
      page: () => VideoDetailScreen(id: Get.arguments as int),
    ),
    GetPage(
      name: Routes.videoList,
      page: () => VideoListPage(id: Get.arguments as int),
    ),
    GetPage(
      name: Routes.feedDetail,
      page: () => FeedDetailScreen(id: Get.arguments as int),
    ),
    GetPage(
      name: Routes.feedPost,
      page: () => FeedPostScreen(boardInfoList: Get.arguments as List<BoardInfo>),
    ),
  ];
}
