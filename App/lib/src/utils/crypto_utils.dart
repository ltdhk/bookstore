import 'dart:convert';
import 'package:crypto/crypto.dart';

class CryptoUtils {
  /// MD5加密
  static String md5Encrypt(String input) {
    final bytes = utf8.encode(input);
    final digest = md5.convert(bytes);
    return digest.toString();
  }
}
