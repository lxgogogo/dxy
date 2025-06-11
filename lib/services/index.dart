library services;

import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:google_api_availability/google_api_availability.dart';
import 'package:holdem/model/res_base_model.dart';
import 'package:holdem/utils/api.dart';
import 'package:holdem/utils/devices_util.dart';
import 'package:holdem/utils/env.dart';
import 'package:holdem/utils/http_utils.dart';

import '../model/catpcha_result.dart';
import '../utils/log_util.dart';
import '../utils/toast_utils.dart';

part 'common_service.dart';
part 'firebase.dart';
part 'login_service.dart';
part 'user_service.dart';
