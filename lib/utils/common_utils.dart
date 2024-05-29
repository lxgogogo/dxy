import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///不带参数事件
// onTap: CommonUtils.debounce(_showDevices)
// 带参数事件
// onPressed: CommonUtils.debounce((){
//          }),
class CommonUtils{
  static final Map<String, Debouncer> _debouncers = {};

  static Debouncer getDebouncer(String key, {Duration debounceDuration = const Duration(seconds: 3)}) {
    var debouncer = _debouncers[key];
    if (debouncer == null) {
      debouncer = Debouncer(debounceDuration: debounceDuration);
      _debouncers[key] = debouncer;
    }
    return debouncer;
  }

  static bool isAndroid(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.android;
  }
}

class Debouncer {
  final Duration debounceDuration;
  Timer? _timer;

  Debouncer({required this.debounceDuration});

  void run(VoidCallback callback) {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
      return;
    }

    _timer = Timer(debounceDuration, (){
      _timer = null;
    });
    callback();
  }
}
