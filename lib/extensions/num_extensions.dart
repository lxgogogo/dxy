extension NumExtension on num? {
  String get abbreviateNumber {
    if (this == null) return '0';
    if (this! >= 0 && this! <= 999) {
      return toString();
    } else if (this! >= 1000 && this! <= 999949) {
      double result = (this! + 0.1) / 1000;
      return '${result.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}K';
    } else if (this! >= 999950 && this! <= 999949999) {
      double result = (this! + 0.1) / 1000000;
      return '${result.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}M';
    } else if (this! >= 999950000 && this! <= 999949999999) {
      double result = (this! + 0.1) / 1000000000;
      return '${result.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}B';
    } else {
      double result = (this! + 0.1) / 1000000000000;
      if (result > 999.9) {
        return '999.9T';
      } else {
        return '${result.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}T';
      }
    }
  }
}
