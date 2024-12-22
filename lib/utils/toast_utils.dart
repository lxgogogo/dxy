import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart' as OkToast;
import 'package:oktoast/oktoast.dart'; //

class ToastUtils {
  static showToast(String msg) {
    // Fluttertoast.showToast(
    //     msg: msg,
    //     gravity: ToastGravity.CENTER,
    //     textColor: Colors.white,
    //     fontSize: 15.0,
    //     toastLength: Toast.LENGTH_SHORT,
    //     backgroundColor: Colors.grey,
    //     webPosition:ToastGravity.CENTER,
    // );

    OkToast.showToast(
        msg,
        duration: const Duration(seconds: 2),
        position: ToastPosition.center,
        backgroundColor: Colors.black.withOpacity(0.8),
        textPadding: EdgeInsets.all(15),
        radius: 25
    );
  }
}
