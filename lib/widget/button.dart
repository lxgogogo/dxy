import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String title;
  final Color textColor;
  final double? radius;
  final double width;
  final double height;
  final double fontSize;
  final FontWeight fontWeight;
  final bool disable;
  final bool showOpacityAnimation;
  final bool isCancel;

  const CustomButton({
    super.key,
    this.onPressed,
    required this.title,
    this.radius,
    this.width = double.infinity,
    this.height = 50.0,
    this.fontSize = 15,
    this.fontWeight = FontWeight.w500,
    this.textColor = const Color(0xffdff3ff),
    this.disable = false,
    this.showOpacityAnimation = true,
    this.isCancel = false,
  });

  @override
  Widget build(BuildContext context) {
    return showOpacityAnimation
        ? FutureBuilder(
            builder: (BuildContext context, snapshot) {
              return _buildThemeContainer(snapshot.data ?? 1.0);
            },
            future: opacityFuture(),
            initialData: disable ? 0.0 : 1.0,
          )
        : _buildThemeContainer(disable ? 0.5 : 1.0);
  }

  AnimatedOpacity _buildThemeContainer(double opacity) {
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height / 2),
          image: DecorationImage(
            image: AssetImage(isCancel ? 'assets/images/logout_btn.png' : 'assets/images/login_btn.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: ElevatedButton(
          onPressed: disable ? null : onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(width, height),
            shadowColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(height * 0.5),
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Future<double> opacityFuture() {
    return Future.delayed(const Duration(milliseconds: 0), () {
      return disable ? 0.5 : 1.0;
    });
  }
}
