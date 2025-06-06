import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/safe_update_extensions.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/widget/common_app_bar.dart';

import '../../gen/assets.gen.dart';
import '../../model/course_model.dart';
import '../../routes/app_pages.dart';
import '../../routes/app_routes_utils.dart';
import '../../services/course_service.dart';
import '../../utils/log_util.dart';
import '../../utils/toast_utils.dart';
import '../../widget/no_network.dart';

part 'winning_streak_binding.dart';

part 'winning_streak_controller.dart';

class WinningStreakScreen extends StatefulWidget {
  const WinningStreakScreen({Key? key}) : super(key: key);

  @override
  State<WinningStreakScreen> createState() => _WinningStreakScreenState();
}

class _WinningStreakScreenState extends State<WinningStreakScreen> {
  final WinningStreakController controller = Get.put(WinningStreakController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WinningStreakController>(
      init: WinningStreakController(),
      tag: '${Get.arguments}',
      builder: (controller) {
        return Scaffold(
          appBar: CommonAppBar.arrowBack(
            context,
            title: '连胜',
          ),
          backgroundColor: '#F7F8FC'.hexColor,
          body: controller.detailBean == null
              ? const SizedBox()
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [],
                    ),
                  ),
                ),
        );
      },
    );
  }

  @override
  void dispose() {
    Get.delete<WinningStreakController>();
    super.dispose();
  }
}
