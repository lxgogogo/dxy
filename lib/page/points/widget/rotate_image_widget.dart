import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RotateImageDemo extends StatefulWidget {

  final Function onTap;
  const RotateImageDemo ({super.key, required this.onTap});

  @override
  createState() => _RotateImageDemoState();
}

class _RotateImageDemoState extends State<RotateImageDemo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  void _onTap() {
    _controller.reset();
    _controller.forward();
    widget.onTap();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500), // 动画持续时间
      vsync: this,
    ); // 重复动画

    _animation = Tween<double>(begin: 0, end: 1 * 3.14159265359).animate(_controller) // 360度 = 2π 弧度
      ..addListener(() {
        if (mounted) {
          setState(() {
            // 这将触发重绘，从而更新Transform组件的旋转角度
          });
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: _animation.value,
      child: GestureDetector(
        onTap: _onTap,
        child: Image.asset(
          'assets/images/icon_points_change.png',
          width: 32.w,
          height: 32.w,
        ),
      )
    );
  }
}
