
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CourseChallengeAlert {
  
  static show (id) {
    //Get.dialog(CourseChallengeWidget(id: id));
  }
}

class CourseChallengeWidget extends StatefulWidget {

  final int id;
  const CourseChallengeWidget({super.key, required this.id});
  
  @override
  State<StatefulWidget> createState() {
    return _CourseChallengeWidgetState();
  }
}

class _CourseChallengeWidgetState extends State<CourseChallengeWidget> {
  
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}