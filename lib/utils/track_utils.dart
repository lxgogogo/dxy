import 'package:flutter/material.dart';

import 'api.dart';
import 'http_utils.dart';

class TrackUtils {
  static Future<void> trackEvent({
    required String category,
    required String action,
    Map<String, dynamic>? parameters,
  }) async {
    final Map<String, dynamic> params = {
      'category': category,
      'action': action,
      if (parameters != null) 'params': parameters,
    };

    try {
      await HttpUtils.postNew(Api.trackEvent, params: params);
    } catch (e, stack) {
      debugPrint('埋点失败: $e\n$stack');
    }
  }

  static VoidCallback trackedTap({
    VoidCallback? onTap,
    required String category,
    required String action,
    Map<String, dynamic>? parameters,
  }) {
    return () {
      onTap?.call();
      trackEvent(
        category: category,
        action: action,
        parameters: parameters,
      );
    };
  }
}
