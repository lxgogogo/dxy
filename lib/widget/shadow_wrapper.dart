import 'package:flutter/material.dart';

class ShadowWrapper extends StatelessWidget {
  final Widget child;
  final EdgeInsets? margin;
  final double borderRadius;

  const ShadowWrapper({
    super.key,
    required this.child,
    this.margin,
    this.borderRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: -2.5,
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(borderRadius),
                ),
                // gradient: const LinearGradient(
                //   colors: [
                //     Color(0xff799DBC),
                //     Color(0xffAFCEE9),
                //     Color(0xff7A9EBD),
                //     Color(0xff85A8C6),
                //     Color(0xffB0CEE8),
                //     Color(0xff85A8C6),
                //     Color(0xff7A9EBD),
                //     Color(0xffADCCE8),
                //     Color(0xff7A9EBD),
                //   ],
                //   stops: [
                //     0,
                //     0.03,
                //     0.05,
                //     0.23,
                //     0.5,
                //     0.8,
                //     0.96,
                //     0.97,
                //     100,
                //   ],
                // ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            top: 0,
            right: 0,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(borderRadius),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.white,
                        ),
                        BoxShadow(
                          color: Colors.white70,
                          spreadRadius: -5.0,
                          blurRadius: 20.0,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(borderRadius),
                      ),
                      // boxShadow: const [
                      //   BoxShadow(
                      //     color: Color(0xffB9D0E5),
                      //   ),
                      //   BoxShadow(
                      //     color: Colors.white,
                      //     spreadRadius: 0,
                      //     blurRadius: 1.5,
                      //     offset: Offset(0, -1),
                      //   ),
                      // ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 1.5,
            left: 0,
            right: 0,
            bottom: 2.5,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(borderRadius),
                ),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF6FAFE),
                    Color(0xFFF6FAFE),
                  ],
                  stops: [0, 1],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.white,
                    spreadRadius: -1.5,
                    blurRadius: 1.5,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
