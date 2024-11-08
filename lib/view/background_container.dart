import 'package:flutter/material.dart';
class BackgroundContainer extends StatelessWidget {
  final Widget? child;
  const BackgroundContainer({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(244, 247, 252, 1),
              Color.fromRGBO(228, 238, 249, 1),
              Color.fromRGBO(228, 238, 249, 1),
            ],
            stops: [
              0.0,
              0.2,
              1.0,
            ]
          ),
        ),
        child: child,
      ),
    );
  }
}
