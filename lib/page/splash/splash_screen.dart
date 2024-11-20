import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holdem/routes/app_pages.dart';
import 'package:holdem/utils/third_sdk_config.dart';

part 'splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
        init: SplashController(),
        builder: (_) => Scaffold(
              extendBodyBehindAppBar: true,
              body: Image.asset(
                'assets/images/splash_bg.png',
                fit: BoxFit.fill,
              ),
            ));
  }
}
