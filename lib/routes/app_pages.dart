import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/model/board_info.dart';
import 'package:holdem/page/article_detail/article_detail_screen.dart';
import 'package:holdem/page/at_user/at_user_screen.dart';
import 'package:holdem/page/book_detail/book_detail_screen.dart';
import 'package:holdem/page/bool_list/book_list_screen.dart';
import 'package:holdem/page/equity_center/equity_center_view.dart';
import 'package:holdem/page/feed_detail/feed_detail_screen.dart';
import 'package:holdem/page/feed_list/feed_list_screen.dart';
import 'package:holdem/page/feed_post/feed_post_screen.dart';
import 'package:holdem/page/following/following_screen.dart';
import 'package:holdem/page/forget_password/forget_password_screen.dart';
import 'package:holdem/page/home/home_screen.dart';
import 'package:holdem/page/login/login_screen.dart';
import 'package:holdem/page/main/main_screen.dart';
import 'package:holdem/page/message/notice/message_notice_detail_view.dart';
import 'package:holdem/page/message/notice/message_notice_view.dart';
import 'package:holdem/page/mine/collect/collect_list_view.dart';
import 'package:holdem/page/mine/collect/creat_collect_group_view.dart';
import 'package:holdem/page/mine/collect/finish_creat_collect_group_view.dart';
import 'package:holdem/page/personal/personal_screen.dart';
import 'package:holdem/page/revise/delete_account/delete_account_view.dart';
import 'package:holdem/page/revise/revise_account/revise_account_view.dart';
import 'package:holdem/page/revise/revise_email/revise_email_view.dart';
import 'package:holdem/page/revise/revise_password/revise_password_view.dart';
import 'package:holdem/page/revise/revise_phone/revise_phone_view.dart';
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
import '../page/telegram_login/telegram_login_screen.dart';
import '../page/tool_detail/tool_detail_screen.dart';
import '../page/tool_list/tool_list_screen.dart';
import '../utils/track_utils.dart';

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
      name: Routes.following,
      page: () => FollowingScreen(isFollowPage: Get.arguments as bool),
    ),
    GetPage(
      name: Routes.bookDetail,
      page: () => const BookDetailScreen(),
    ),
    GetPage(
      name: Routes.toolDetail,
      page: () => const ToolDetailScreen(),
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
      name: Routes.toolList,
      page: () => const ToolListScreen(),
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
    GetPage(
      name: Routes.equityCenter,
      page: () => const EquityCenterPage(),
    ),
    GetPage(
      name: Routes.telegramLogin,
      page: () => const TelegramLoginScreen(),
    ),
    GetPage(
      name: Routes.noticeList,
      page: () => const MessageNoticePage(),
    ),
    GetPage(
      name: Routes.noticeDetail,
      page: () => const MessageNoticeDetailPage(),
    ),

    GetPage(
      name: Routes.reviseAccount,
      page: () => const ReviseAccountPage(),
    ),
    GetPage(
      name: Routes.reviseEmail,
      page: () => const ReviseEmailPage(),
    ),
    GetPage(
      name: Routes.revisePassword,
      page: () => const RevisePasswordPage(),
    ),
    GetPage(
      name: Routes.revisePhone,
      page: () => const RevisePhonePage(),
    ),
    GetPage(
      name: Routes.deleteAccount,
      page: () => const DeleteAccountPage(),
    ),
  ];
}
