import 'package:chewie/src/animated_play_pause.dart';
import 'package:flutter/material.dart';

class CenterPlayButton extends StatelessWidget {
  const CenterPlayButton({
    super.key,
    required this.backgroundColor,
    this.iconColor,
    required this.show,
    required this.isPlaying,
    required this.isFinished,
    this.onPressed,
  });

  final Color backgroundColor;
  final Color? iconColor;
  final bool show;
  final bool isPlaying;
  final bool isFinished;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.transparent,
      child: Center(
        child: UnconstrainedBox(
          child: AnimatedOpacity(
            opacity: show ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
              child: GestureDetector(
                onTap: onPressed,
                child: isFinished
                    ? Icon(Icons.replay, color: iconColor)
                    : AnimatedPlayPause(
                        color: iconColor,
                        playing: isPlaying,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
