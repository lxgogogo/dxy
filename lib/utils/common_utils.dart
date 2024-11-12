import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  static String timeFromNow(DateTime dt){
    final now = DateTime.now();
    final difference = now.difference(dt);

    String timeInterval;
    if (difference.inMinutes < 1) {
      timeInterval = '刚刚';
    } else if (difference.inHours < 1) {
      timeInterval = '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      timeInterval = '${difference.inHours}小时前';
    } else if (difference.inDays < 5) {
      timeInterval = '${difference.inDays}天前';
    } else {
      final formatter = DateFormat('yyyy-MM-dd HH:mm');
      timeInterval = formatter.format(dt);
    }
    return timeInterval;
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
