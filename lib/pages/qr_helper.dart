import 'package:encrypt/encrypt.dart';

class QRHelper {
  static final _key = Key.fromUtf8('my32lengthsupersecretnooneknows1'); // 32 chars key
  static final _iv = IV.fromLength(16); // 16 bytes IV for AES

  /// Encrypt the data and return the encrypted string
  static String encryptData(String data) {
    final encrypter = Encrypter(AES(_key));
    return encrypter.encrypt(data, iv: _iv).base64;
  }
}
