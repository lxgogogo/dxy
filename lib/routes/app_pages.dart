import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/model/board_info.dart';
import 'package:holdem/page/article_detail/article_detail_screen.dart';
import 'package:holdem/page/at_user/at_user_screen.dart';
import 'package:holdem/page/book_detail/book_detail_screen.dart';
import 'package:holdem/page/bool_list/book_list_screen.dart';
import 'package:holdem/page/comment_input/comment_input_screen.dart';
import 'package:holdem/page/comment_list/comment_list_screen.dart';
import 'package:holdem/page/competition_calendar/competition_calendar_screen.dart';
import 'package:holdem/page/competition_detail/competition_detail_screen.dart';
import 'package:holdem/page/feed_detail/feed_detail_screen.dart';
import 'package:holdem/page/feed_list/feed_list_screen.dart';
import 'package:holdem/page/feed_post/feed_post_screen.dart';
import 'package:holdem/page/following/following_screen.dart';
import 'package:holdem/page/forget_password/forget_password_screen.dart';
import 'package:holdem/page/home/home_screen.dart';
import 'package:holdem/page/article_detail/article_detail_screen.dart';
import 'package:holdem/page/book_detail/book_detail_screen.dart';
import 'package:holdem/page/mine/collect/collect_list_view.dart';
import 'package:holdem/page/mine/collect/creat_collect_group_view.dart';
import 'package:holdem/page/mine/collect/finish_creat_collect_group_view.dart';
import 'package:holdem/page/personal/personal_screen.dart';
import 'package:holdem/page/search_tag/search_tag_screen.dart';
import 'package:holdem/page/terms_privacy/terms_privacy_screen.dart';
import 'package:holdem/page/video_detail/video_detail_screen.dart';
import 'package:holdem/page/main/main_screen.dart';
import 'package:holdem/page/login/login_screen.dart';
import 'package:holdem/page/main/main_screen.dart';
import 'package:holdem/page/personal/personal_screen.dart';
import 'package:holdem/page/reply_list/reply_list_screen.dart';
import 'package:holdem/page/scan/scan_screen.dart';
import 'package:holdem/page/scan_result/scan_result_screen.dart';
import 'package:holdem/page/search/search_screen.dart';
import 'package:holdem/page/search_tag/search_tag_screen.dart';
import 'package:holdem/page/setting/setting_screen.dart';
import 'package:holdem/page/splash/splash_screen.dart';
import 'package:holdem/page/terms_privacy/terms_privacy_screen.dart';
import 'package:holdem/page/video_detail/video_detail_screen.dart';
import 'package:holdem/page/video_list/video_list_screen.dart';
import 'package:holdem/services/index.dart';

import '../page/course/course_screen.dart';

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
      name: Routes.termsAndPrivacy,
      page: () => const TermsPrivacyPage(),
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
      name: Routes.searchTag,
      page: () => const SearchTagScreen(),
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
    // GetPage(
    //   name: Routes.publishComment,
    //   page: () => const CommentPublishScreen(),
    // ),
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
      page: () => const BookDetailScreen(),
    ),
    GetPage(
      name: Routes.articleDetail,
      page: () => const ArticleDetailScreen(),
    ),
    GetPage(
      name: Routes.videoDetail,
      page: () => const VideoDetailScreen(),
    ),
    GetPage(
      name: Routes.feedDetail,
      page: () => const FeedDetailScreen(),
    ),
    GetPage(
      name: Routes.feedPost,
      page: () =>
          FeedPostScreen(boardInfoList: Get.arguments as List<BoardInfo>),
    ),
    GetPage(
      name: Routes.personal,
      page: () => const PersonalScreen(),
    ),
    GetPage(
      name: Routes.competitionCalendar,
      page: () => const CompetitionCalendarScreen(),
    ),
    GetPage(
      name: Routes.competitionDetail,
      page: () => CompetitionDetailScreen(id: Get.arguments as int?),
    ),
    GetPage(
      name: Routes.course,
      page: () => const CourseScreen(),
    ),
    GetPage(
      name: Routes.videoList,
      page: () => const VideoListScreen(),
    ),
    GetPage(
      name: Routes.boolList,
      page: () => const BookListScreen(),
    ),
    GetPage(
      name: Routes.scan,
      page: () => const ScanScreen(),
    ),
    GetPage(
      name: Routes.scanResult,
      page: () => const ScanResultScreen(),
    ),
    GetPage(
      name: Routes.createCollect,
      page: () => const CreatCollectGroupPage(),
    ),
    GetPage(
      name: Routes.finishCreateCollect,
      page: () => const FinishCreatCollectGroupPage(),
    ),
    GetPage(
      name: Routes.collectList,
      page: () => const CollectListPage(),
    ),
  ];
}
