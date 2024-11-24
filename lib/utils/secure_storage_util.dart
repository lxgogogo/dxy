import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageUtil {
  static final SecureStorageUtil of = SecureStorageUtil._();
  SecureStorageUtil._();

  final _storage = const FlutterSecureStorage();

  void write(String key, String value) {
    _storage.write(key: key, value: value);
  }

  // read
  Future<String?> read(String key) {
    return _storage.read(key: key);
  }

  // delete
  void delete(String key) {
    _storage.delete(key: key);
  }
}
