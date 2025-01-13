import 'package:get/get.dart';
import 'package:holdem/services/index.dart';

import '../model/report_type_model.dart';
import '../utils/log_util.dart';

class ConfigStore extends GetxController {
  static ConfigStore get of => Get.find();

  List<ReportTypeModel> reportTypes = [];

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
