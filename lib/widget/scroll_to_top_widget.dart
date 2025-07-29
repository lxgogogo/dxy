import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';

import '../gen/assets.gen.dart';

class ScrollToTopWidget extends StatefulWidget {
  final ScrollController scrollController;
  final Widget child;
  final double scrollThreshold;
  final double? bottom;

  const ScrollToTopWidget(
      {super.key, required this.scrollController, required this.child, this.scrollThreshold = 0.25, this.bottom});

  @override
  State<ScrollToTopWidget> createState() => _ScrollToTopWidgetState();
}

class _ScrollToTopWidgetState extends State<ScrollToTopWidget> {
  late ValueNotifier<bool> _isVisibleNotifier;

  @override
  void initState() {
    super.initState();
    _isVisibleNotifier = _isVisibleNotifier = ValueNotifier(false);
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _isVisibleNotifier.dispose();
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!widget.scrollController.hasClients) {
      return;
    }

    final shouldShow = widget.scrollController.offset > 1.sh * widget.scrollThreshold;

    if (shouldShow != _isVisibleNotifier.value) {
      _isVisibleNotifier.value = shouldShow;
    }
  }

  void _scrollToTop() {
    widget.scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.linear,
    );
  }

  @override
  Widget build(BuildContext context) {
    double bottom = widget.bottom ?? 30.w; //kToolbarHeight + 30.w
    return Stack(
      children: [
        widget.child,
        Positioned(
          right: 16.w,
          bottom: bottom,
          child: ValueListenableBuilder<bool>(
            valueListenable: _isVisibleNotifier,
            builder: (context, isVisible, child) {
              if (!isVisible) {
                return const SizedBox();
              }
              return GestureDetector(
                onTap: _scrollToTop,
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: '#0050FF1A'.hexColor.withOpacity(0.1),
                        blurRadius: 6.67.r,
                      )
                    ],
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    Assets.svg.iconToTop,
                    width: 40.w,
                    height: 40.w,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

extension ScrollWrapper on Widget {
  Widget scrollToTopWrapper(ScrollController scrollController, {double? bottom}) {
    return ScrollToTopWidget(
      bottom: bottom,
      scrollController: scrollController,
      child: this,
    );
  }
}
