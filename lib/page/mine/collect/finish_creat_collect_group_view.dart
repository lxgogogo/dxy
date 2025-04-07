import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../../widget/common_app_bar.dart';
import '../../../widget/common_done_button.dart';
import 'finish_creat_collect_group_controller.dart';

class FinishCreatCollectGroupPage extends StatefulWidget {
  const FinishCreatCollectGroupPage({Key? key}) : super(key: key);

  @override
  State<FinishCreatCollectGroupPage> createState() =>
      _FinishCreatCollectGroupPageState();
}

class _FinishCreatCollectGroupPageState
    extends State<FinishCreatCollectGroupPage> {
  final FinishCreatCollectGroupController controller =
      Get.put(FinishCreatCollectGroupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CommonAppBar.arrowBack(context, title: '从全部收藏中选择', actions: [
      CommonDoneButton(
          title: '完成',
          margin: EdgeInsets.only(right: 12.w),
          signUpOnTap: () {
            Get.toNamed(Routes.finishCreateCollect);
          })
    ]));
  }

  @override
  void dispose() {
    Get.delete<FinishCreatCollectGroupController>();
    super.dispose();
  }
}
