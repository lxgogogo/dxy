import 'package:flutter/material.dart';
import 'package:holdem/utils/size_fit.dart';

class HoldemNormalBtn extends StatelessWidget {
  Widget child;
  var onTap;
  HoldemNormalBtn({super.key, required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return GestureDetector(
        onTap: onTap,
        child: Container(
            padding: EdgeInsets.only(bottom: 3.px),
            decoration: BoxDecoration(
              //flutter 上下颜色渐变
              //#F9CF3A, #FFD43E00
              borderRadius: BorderRadius.all(Radius.circular(15.px)),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF8cbee9),
                  Color(0xFFbed6eb),
                  Color(0xFF8cbee9),
                  Color(0xFFc2d8eb),
                  Color(0xFF8cbee9),
                  Color(0xFFc1d7eb),
                  Color(0xFF8cbee9),
                  Color(0xFFbed6eb),
                  Color(0xFF8cbee9),
                  // Color.fromRGBO(140, 190, 233, 1),
                  // Color.fromRGBO(190, 214, 235, 1),
                  // Color.fromRGBO(140, 190, 233, 1),
                  // Color.fromRGBO(194, 216, 235, 1),
                  // Color.fromRGBO(140, 190, 233, 1),
                  // Color.fromRGBO(193, 215, 235, 1),
                  // Color.fromRGBO(140, 190, 233, 1),
                ],
              ),
            ),
            child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xff30AEFB),
                  borderRadius: BorderRadius.all(Radius.circular(15.px)),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFEEF7FE),
                      Color(0xFFDAEDFC),
                      Color(0xffB6DEFF)
                    ],
                  ),
                ),
                padding:
                    EdgeInsets.symmetric(horizontal: 13.px, vertical: 5.px),
                child: child)));
  }
}


// ignore: must_be_immutable
class HoldemHighlightBtn extends StatelessWidget {
  Widget child;
  var onTap;
  HoldemHighlightBtn({super.key, required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return GestureDetector(
        onTap: onTap,
        child: Container(
            padding: EdgeInsets.only(bottom: 3.px),
            decoration: BoxDecoration(
              //flutter 上下颜色渐变
              //#F9CF3A, #FFD43E00
              borderRadius: BorderRadius.all(Radius.circular(15.px)),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF3275F2),
                  Color(0xFF52C0FC),
                  Color(0xFF1E92F6),
                  Color(0xFF1E92F6),
                  Color(0xFF3DB4FD),
                  Color(0xFF1E92F6),
                  Color(0xFF1E92F6),
                  Color(0xFF52C0FC),
                  Color(0xFF3275F2),
                  // Color.fromRGBO(140, 190, 233, 1),
                  // Color.fromRGBO(190, 214, 235, 1),
                  // Color.fromRGBO(140, 190, 233, 1),
                  // Color.fromRGBO(194, 216, 235, 1),
                  // Color.fromRGBO(140, 190, 233, 1),
                  // Color.fromRGBO(193, 215, 235, 1),
                  // Color.fromRGBO(140, 190, 233, 1),
                ],
              ),
            ),
            child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xff30AEFB),
                  borderRadius: BorderRadius.all(Radius.circular(15.px)),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF63C2FF),
                      Color(0xFF1FA7FF),
                      Color(0xFF0775FA),
                    ],
                  ),
                ),
                padding:
                    EdgeInsets.symmetric(horizontal: 13.px, vertical: 5.px),
                child: child)));
  }
}
