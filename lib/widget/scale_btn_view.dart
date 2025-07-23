import 'package:flutter/cupertino.dart';

class ViewClick extends StatefulWidget {
  const ViewClick(
      {super.key,
      required this.child,
      this.behavior,
      this.onTapDown,
      this.onTapUp,
      this.onTap,
      this.onTapCancel,
      this.x = 0,
      this.y = 0,
      this.aniDuration = 80,
      this.scaleValue = 0.95,
      this.offRatio = 0.01});

  final HitTestBehavior? behavior;

  final Widget? child;

  final GestureTapDownCallback? onTapDown;

  final GestureTapUpCallback? onTapUp;

  final GestureTapCallback? onTap;

  final GestureTapCancelCallback? onTapCancel;

  final double x;

  final double y;

  final int aniDuration;

  final double scaleValue;

  final double offRatio;

  @override
  State<ViewClick> createState() => _ViewClick(x, y, aniDuration, scaleValue, offRatio);
}

class _ViewClick extends State<ViewClick> with TickerProviderStateMixin {
  _ViewClick(this.x, this.y, this.aniDuration, this.scaleValue, this.offRatio);

  final double x;

  final double y;

  final int aniDuration;

  final double scaleValue;

  final double offRatio;

  double viewScale = 1.0;

  Offset postionoffset = const Offset(0, 0);

  // 动画控制器 点击触发播放动画
  late AnimationController _scaleAnimationController;
  late AnimationController _curtAnimationController;

  // 非线性动画 用来实现点击效果
  late Animation<double> _animation;
  late Animation<Offset> _offanimation;

  late Duration duration;

  @override
  void initState() {
    super.initState();
    // 初始化 Controller
    _scaleAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: aniDuration),
    );
    _animation = Tween<double>(begin: 1.0, end: scaleValue).animate(_scaleAnimationController);
    _curtAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: aniDuration));
    _offanimation = Tween(
      begin: const Offset(0.0, 0.0),
      end: Offset(0.0, y * offRatio),
    ).animate(_curtAnimationController);
  }

  void _playAnimation() {
    _scaleAnimationController.forward();
    _curtAnimationController.forward();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scaleAnimationController.dispose();
    _curtAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    Widget? current = widget.child;
    GestureTapDownCallback? onTapDown = widget.onTapDown;
    GestureTapUpCallback? onTapUp = widget.onTapUp;
    GestureTapCallback? onTap = widget.onTap;
    GestureTapCancelCallback? onTapCancel = widget.onTapCancel;
    return IgnorePointer(
      child: GestureDetector(
        behavior: widget.behavior,
        child: SlideTransition(
            transformHitTests: true,
            textDirection: TextDirection.rtl,
            position: _offanimation,
            child: ScaleTransition(scale: _animation, alignment: Alignment.center, child: current)),
        onTap: () {
          if (onTap != null) {
            onTap!();
          }
          _scaleAnimationController.reverse(from: 1.0);
          _curtAnimationController.reverse(from: 1.0);
        },
        onTapCancel: () {
          _scaleAnimationController.reverse(from: 1.0);
          _curtAnimationController.reverse(from: 1.0);
          viewScale = 1.0;
          postionoffset = const Offset(0, 0);
          if (onTapCancel != null) {
            onTapCancel!();
          }
        },
        onTapUp: (event) {
          _scaleAnimationController.reverse(from: 1.0);
          _curtAnimationController.reverse(from: 1.0);
          viewScale = 1.0;
          postionoffset = const Offset(0, 0);
          if (onTapUp != null) {
            onTapUp!(event);
          }
        },
        onTapDown: (event) {
          _playAnimation();
          viewScale = 1.0;
          postionoffset = Offset(x, y);
          if (onTapDown != null) {
            onTapDown!(event);
          }
        },
      ),
      ignoring: false,
    );
  }
}
