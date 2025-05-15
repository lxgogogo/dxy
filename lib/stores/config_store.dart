import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:holdem/services/index.dart';

import '../model/report_type_model.dart';
import '../utils/log_util.dart';

class ConfigStore extends GetxController {
  static ConfigStore get of => Get.find();
  RxBool isOutsideTheWall = false.obs;

  List<ReportTypeModel> reportTypes = [];

  @override
  void onInit() {
    super.onInit();
    checkOutsideTheWall();
  }

  Future<void> checkOutsideTheWall() async {
    try {
      final dioClient = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ));
      final response = await dioClient.get('https://www.google.com/');
      isOutsideTheWall.value = response.statusCode == 200;
    } catch (e) {
      isOutsideTheWall.value = false;
    }
  }

  Future<List<ReportTypeModel>> getReportTypes() async {
    if (reportTypes.isNotEmpty) return reportTypes;
    try {
      final res = await CommonService.of.reportDefined();
      if (res.isSuccess) {
        final listRes = res.data['reportType'] as List? ?? [];
        final records = listRes.map((e) => ReportTypeModel.fromJson(e as Map? ?? {})).toList();
        reportTypes = records;
      }
    } catch (e) {
      Log.d(e.toString());
    }
    return reportTypes;
  }
}
