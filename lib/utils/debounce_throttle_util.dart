import 'dart:async';

class ClickCDInfo {
  int nClickIntervalTime = 500; //点击间隔
  int nLastRequestTime = 0;
  Timer? timer;

  ClickCDInfo(this.nClickIntervalTime);
}

class DebounceThrottle {
  static Timer? _debounceTimer;

  /// 防抖 (传入所要防抖的方法/回调与延迟时间)
  static void debounce(Function func, [int delay = 300]) {
    if (_debounceTimer != null) {
      _debounceTimer?.cancel();
    }
    _debounceTimer = Timer(Duration(milliseconds: delay), () {
      func.call();
      _debounceTimer!.cancel();
      _debounceTimer = null;
    });
  }

  static Timer? _throttleTimer;
  static bool _throttleFlag = true;

  /// 节流 (传入所要节流的方法/回调与延迟时间)
  static void throttle(Function func, [int delay = 300]) {
    // DzLogger.i("_throttleFlag is $_throttleFlag");
    if (_throttleFlag) {
      func.call();
      _throttleFlag = false;
    }
    if (_throttleTimer != null) {
      return;
    }
    _throttleTimer = Timer(Duration(milliseconds: delay), () {
      // DzLogger.i("_throttleTimer执行");

      _throttleFlag = true;
      _throttleTimer!.cancel();
      _throttleTimer = null;
    });
  }

  static Map<int, ClickCDInfo> clickMap = <int, ClickCDInfo>{};

  //带CD的点击 nInterval : 毫秒
  static void clickWithInterval(Function func, {int nInterval = 300}) {
    //如果包含  则表示在CD中 不处理
    if (clickMap.containsKey(func.hashCode)) {
      return;
    } else {
      //先把函数加入map
      ClickCDInfo info = ClickCDInfo(nInterval);
      clickMap[func.hashCode] = info;
      info.timer = Timer(Duration(milliseconds: nInterval), () {
        clickMap.remove(func.hashCode); //到时移除
        info.timer?.cancel();
        info.timer = null;
      });
      func.call();
    }
  }
}
