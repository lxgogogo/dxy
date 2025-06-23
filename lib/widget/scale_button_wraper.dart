import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScaleButtonWrapper extends StatefulWidget {
  const ScaleButtonWrapper({
    super.key,
    required this.child,
    this.behavior,
    this.onTap,
    this.splashColor = Colors.transparent,
    this.highlightColor = Colors.transparent,
    this.borderRadius,
    this.duration = const Duration(milliseconds: 100),
    this.scaleValue = 0.90,
  });

  final HitTestBehavior? behavior;

  final Widget? child;

  final GestureTapCallback? onTap;

  final Duration duration;

  final double scaleValue;

  final Color highlightColor;

  final Color splashColor;

  final BorderRadius? borderRadius;

  @override
  State<ScaleButtonWrapper> createState() => _ScaleButtonWrapperState();
}

class _ScaleButtonWrapperState extends State<ScaleButtonWrapper> with TickerProviderStateMixin {

  late AnimationController _scaleAnimationController;

  late Animation<double> _animation;

  late Duration duration;

  @override
  void initState() {
    super.initState();
    _scaleAnimationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(begin: 1.0, end: widget.scaleValue).animate(_scaleAnimationController);
  }

  void _playAnimation() {
    _scaleAnimationController.forward();
  }

  @override
  void dispose() {
    _scaleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: InkWell(
        splashColor: widget.splashColor,
        highlightColor: widget.highlightColor,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8.r),
        onTap: () {
          widget.onTap?.call();
          _scaleAnimationController.forward().whenComplete(() {
            _scaleAnimationController.reverse();
          });
        },
        onTapCancel: () {
          _scaleAnimationController.reverse();
        },
        onTapUp: (event) {
          _scaleAnimationController.reverse();
        },
        onTapDown: (event) {
          _playAnimation();
        },
        child: widget.child,
      ),
    );
  }
}
