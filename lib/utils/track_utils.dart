import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'api.dart';
import 'http_utils.dart';

class TrackUtils {
  static Future<void> trackEvent({
    required String userLogType,
    dynamic params,
  }) async {
    final nowData = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    final Map<String, dynamic> postParams = {
      'userLogType': 'USER_LOG_$userLogType',
      if (params != null) 'params': params,
      'optAt': nowData,
    };

    try {
      await HttpUtils.postNew(Api.trackEvent, params: postParams);
    } catch (e, stack) {
      debugPrint('埋点失败: $e\n$stack');
    }
  }

  static VoidCallback trackedTap({
    VoidCallback? onTap,
    required String userLogType,
    dynamic params,
  }) {
    return () {
      onTap?.call();
      trackEvent(
        userLogType: userLogType,
        params: params,
      );
    };
  }
}

// 100001
// 100002
// 100003
// 100004
// 100005
// 100006
// 100007
// 100008
// 101001
// 101002
// 101003
// 101004
// 101005
// 101006
// 101007
// 101008
// 101009
// 101010
// 101011
// 101012
// 101013
// 102001
// 103001
// 103002
// 103003
// 103004
// 103005
// 103006
// 103007
// 103008
// 103009
// 103010
// 104001
// 104002
// 105001
// 105002
// 105003
// 105004
// 105005
// 105006
// 105007
// 105008
// 105009
// 106001
// 107001
// 107002
// 107003
// 107004
// 107005
// 107006
// 107007
// 107008
// 107009
// 107010
// 108001
// 108002
// 108003
// 108004
// 108005
// 108006
// 109001
// 109002
// 109003
// 109004
// 109005
// 109006
// 109007
// 109008
// 109009
// 110001
// 110002
// 110003
// 110004
// 111001
// 111002
// 111003
// 111004
// 111005
// 112001
// 112002
// 112003
// 112004
// 113001
// 113002
// 113003
// 113004
// 113005
// 113006
// 113007
// 113008
// 113009
// 113010
// 114001
// 115001
// 115002
// 115003
// 115004
// 115005
// 116001
// 117001
// 118001
// 118002
// 118003
// 118004
// 118005
// 118006
// 118007
// 119001
