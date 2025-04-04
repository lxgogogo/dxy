import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:holdem/extensions/string_extensions.dart';

import '../../../gen/assets.gen.dart';

class ScanAreaRector extends StatefulWidget {
  const ScanAreaRector({super.key, required this.height, required this.width});

  final double height;
  final double width;

  @override
  State<ScanAreaRector> createState() => _ScanAreaRectorState();
}

class _ScanAreaRectorState extends State<ScanAreaRector> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 1500),
    vsync: this,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: widget.height,
          width: widget.width,
          child: Stack(
            children: [
              PositionedTransition(
                rect: RelativeRectTween(
                  begin: RelativeRect.fromSize(
                    Rect.fromLTWH(
                      0,
                      0,
                      widget.width,
                      2,
                    ),
                    Size(widget.width, widget.height),
                  ),
                  end: RelativeRect.fromSize(
                    Rect.fromLTWH(
                      0,
                      widget.height - 2,
                      widget.width,
                      2,
                    ),
                    Size(widget.width, widget.height),
                  ),
                ).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: Curves.linear,
                  ),
                ),
                child: FadeTransition(
                  opacity: Tween(begin: 1.0, end: 0.0).animate(
                    CurvedAnimation(
                      parent: _controller,
                      curve: Curves.easeInToLinear,
                    ),
                  ),
                  child: Container(
                    height: 2,
                    width: widget.width,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          '#557BF6'.hexColor.withOpacity(0),
                          '#557BF6'.hexColor,
                          '#557BF6'.hexColor.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SvgPicture.asset(Assets.svg.icScanArea),
            ],
          ),
        ),
        Positioned(
          bottom: -48.w,
          child: Text(
            '请对准需要识别的二维码',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        )
      ],
    );
  }
}
