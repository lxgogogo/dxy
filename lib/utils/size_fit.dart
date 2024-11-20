import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:holdem/main.dart';

extension IntFit on int{
  double get px {
    return this.w;
  }

  double get rpx {
    return SizeFit.setRpx(toDouble());
  }
}

extension DoubleFit on double{
  double get px{
    return SizeFit.setPx(this);
  }

  double get rpx {
    return SizeFit.setRpx(this);
  }
}

class SizeFit {
  static MediaQueryData? _mediaQueryData;
  static double? screenWidth,screenHeight,rpx,px;
  static void initialize(BuildContext context,{double standardWidth = 750}){
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData!.size.width;
    screenHeight = _mediaQueryData!.size.height;

    if (screenWidth!>900){
      screenWidth = 900;
    }
    rpx = screenWidth!/standardWidth;
    px = screenWidth!/standardWidth*2;
  }

  static double setPx(double size){
    return SizeFit.rpx!*size*2;
  }

  static double setRpx(double size){
    return SizeFit.px!*size/2;
  }
}