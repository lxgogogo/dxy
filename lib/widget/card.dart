import 'package:flutter/material.dart';
import 'package:holdem/utils/size_fit.dart';

class CardView extends StatefulWidget {
  Widget child;
  CardView({super.key, required this.child});

  @override
  State<CardView> createState() => _CardViewState();
}

class _CardViewState extends State<CardView> {
  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return Container(
        padding: EdgeInsets.only(bottom: 2.px),
        // margin: EdgeInsets.only(top: 10.px, left: 16.px, right: 16.px),
        margin: EdgeInsets.only(left: 16.px, right: 16.px, top: 12.px),
        decoration: BoxDecoration(
          //flutter 上下颜色渐变
          //#F9CF3A, #FFD43E00
          borderRadius: BorderRadius.all(Radius.circular(13.px)),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFF7FA3C1),
              Color(0xFFBED6EB),
              Color(0xFF80A3C1),
              Color(0xFFC2D8EB),
              Color(0xFF80A3C1),
              Color(0xFFC1D7EB),
              Color(0xFF87A9C5)
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
            // padding: EdgeInsets.all(12.px),
            decoration: BoxDecoration(
              //flutter 上下颜色渐变
              //#F9CF3A, #FFD43E00
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFEEF7FE),
                  Color(0xFFFFFFFF),
                ],
              ),
              borderRadius: BorderRadius.all(Radius.circular(13.px)),
            ),
            child: widget.child));
  }
}

/*class CardView extends StatelessWidget {
  Widget child;
  const CardView({super.key});

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return Container(
        padding: EdgeInsets.only(bottom: 2.px),
        // margin: EdgeInsets.only(top: 10.px, left: 16.px, right: 16.px),
        margin: EdgeInsets.only(
            left: widget.isBanner ? 12.px : 0,
            right: widget.isBanner ? 12.px : 0,
            top: widget.isBanner ? 12.px : 0),
        decoration: BoxDecoration(
          //flutter 上下颜色渐变
          //#F9CF3A, #FFD43E00
          borderRadius: BorderRadius.all(Radius.circular(13.px)),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFF7FA3C1),
              Color(0xFFBED6EB),
              Color(0xFF80A3C1),
              Color(0xFFC2D8EB),
              Color(0xFF80A3C1),
              Color(0xFFC1D7EB),
              Color(0xFF87A9C5)
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
            // padding: EdgeInsets.all(12.px),
            decoration: BoxDecoration(
              //flutter 上下颜色渐变
              //#F9CF3A, #FFD43E00
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFEEF7FE),
                  Color(0xFFFFFFFF),
                ],
              ),
              borderRadius: BorderRadius.all(Radius.circular(13.px)),
            ),
            child: child));
  }
}*/
