part of 'winning_streak_screen.dart';

class WinningStreakBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WinningStreakController());
  }
}
