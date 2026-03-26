import 'dart:convert';
import 'dart:math';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// AES-256-CBC encryption for journal_entries, karma, naomi, future_letters.
///
/// Wire format: `<base64(iv)>:<base64(ciphertext)>` (both standard base64).
/// The 32-byte key is generated once per device, stored in the secure keystore,
/// and never leaves the device.
class EncryptionService {
  static final EncryptionService _instance = EncryptionService._();
  factory EncryptionService() => _instance;
  EncryptionService._();

  static const _keyAlias = 'sobersteps_enc_key';
  final _storage = const FlutterSecureStorage();
  Key? _cachedKey;

  Future<Key> _getOrCreateKey() async {
    if (_cachedKey != null) return _cachedKey!;
    var stored = await _storage.read(key: _keyAlias);
    if (stored == null) {
      final bytes = List<int>.generate(32, (_) => Random.secure().nextInt(256));
      stored = base64Encode(bytes);
      await _storage.write(key: _keyAlias, value: stored);
    }
    _cachedKey = Key(base64Decode(stored));
    return _cachedKey!;
  }

  Future<String> encrypt(String plaintext) async {
    final key = await _getOrCreateKey();
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    return '${base64Encode(iv.bytes)}:${encrypted.base64}';
  }

  Future<String> decrypt(String ciphertext) async {
    // Legacy format written before v1.0: `<64-char hex hmac>:<base64(plaintext)>`.
    // The hex HMAC is always exactly 64 chars; the new IV segment is always 24 base64 chars.
    // Detect by first-segment length so existing dev/test data degrades gracefully.
    final parts = ciphertext.split(':');
    if (parts.length != 2) return ciphertext;
    if (parts[0].length == 64) {
      // Legacy: second segment is plain base64-encoded UTF-8 text.
      return utf8.decode(base64Decode(parts[1]));
    }
    final key = await _getOrCreateKey();
    final iv = IV(base64Decode(parts[0]));
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    return encrypter.decrypt64(parts[1], iv: iv);
  }
}
