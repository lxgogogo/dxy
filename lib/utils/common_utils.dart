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

  static String thousandthPercentile(String price,
      {bool isShowCurrency = true,
        bool showAdd = false,
        String currencySymbol = '',
        int decimalLength = 4,
        bool showMoreZero = true}) {
    if (!isShowCurrency) {
      currencySymbol = "";
    }
    String zero = '';
    for (int i = 0; i < decimalLength; i++) {
      zero += '0';
    }
    if (price.isEmpty) {
      return "${currencySymbol}0.$zero";
    }
    if (price == "0" ||
        price == "0.0" ||
        price == "0.00" ||
        price == "0.000" ||
        price == "0.0000" ||
        price == "null") {
      return "${currencySymbol}0.$zero";
    }
    bool isNegative = false;
    if (price.contains("-")) {
      isNegative = true;
      price = price.replaceAll("-", "");
    }
    if (price.length < 3) {
      String s = "";
      if (isNegative) {
        s = "-";
      } else {
        if (showAdd) {
          s = '+';
        }
      }
      return "$s$currencySymbol$price";
    }
    var array = price.split(".");
    String newPrice = price;
    String decimalPrice = "";
    if (array.length == 2) {
      newPrice = array[0];
      decimalPrice = array[1];
      if (decimalPrice.length > decimalLength) {
        decimalPrice = decimalPrice.substring(0, decimalLength);
      }
      if (decimalPrice == "0" || decimalPrice == "00") {
        decimalPrice = zero;
      }
    }
    if (newPrice.length < 3) {
      String s = "";
      if (isNegative) {
        s = "-";
      } else {
        if (showAdd) {
          s = '+';
        }
      }
      if (decimalPrice.isNotEmpty) {
        return "$s$currencySymbol$newPrice.$decimalPrice";
      } else {
        // 去除末尾0
        //String lessPrice = '${Decimal.tryParse(newPrice) ?? 0}';
        s = double.tryParse(newPrice) == 0 ? "" : s;
        return "$s$currencySymbol$newPrice";
      }
    }
    String priceInText = "";
    int counter = 0;
    for (int i = (newPrice.length - 1); i >= 0; i--) {
      counter++;
      String str = newPrice[i];
      if ((counter % 3) != 0 && i != 0) {
        priceInText = "$str$priceInText";
      } else if (i == 0) {
        priceInText = "$str$priceInText";
      } else {
        priceInText = ",$str$priceInText";
      }
    }
    String newPrices = "";
    String s = "";
    if (isNegative) {
      s = "-";
    } else {
      if (showAdd) {
        s = '+';
      }
    }
    if (array.length == 1) {
      newPrices = "$s$currencySymbol${priceInText.trim()}";
    } else {
      String dprice = "0.$decimalPrice";
      // 去除末尾0
      //dprice = '${Decimal.tryParse(dprice) ?? 0}';
      if (dprice == "0" || dprice == "0.0" || dprice == "0.00") {
        dprice = '.$zero';
      } else {
        dprice = ".${dprice.substring(2)}";
      }
      newPrices = "$s$currencySymbol${priceInText.trim()}$dprice";
    }
    return newPrices;
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
