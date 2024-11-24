extension HexStringExtension on int? {
  String get toHex {
    if (this == null) return '';
    return this!.toRadixString(16).toUpperCase();
  }
}
