

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:holdem/utils/app_theme.dart';

class ToastUtils  {
  static showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        gravity: ToastGravity.CENTER,
        textColor: Colors.white,
        fontSize: 15.0
    );
  }
}