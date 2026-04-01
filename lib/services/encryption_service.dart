import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// AES-256-GCM at rest for karma/naomi/RTS payloads. Key in [FlutterSecureStorage].
/// Does not protect against rooted devices, malware, or OS backup extraction—only casual file reads.
/// Legacy `digest:base64_plain` decrypts with HMAC verification; new writes use [encrypt] v2 format.
class EncryptionService {
  static final EncryptionService _instance = EncryptionService._();
  factory EncryptionService() => _instance;
  EncryptionService._();

  static const _keyAlias = 'sobersteps_enc_key';
  static const _v2Prefix = 'v2:';
  final _storage = const FlutterSecureStorage();
  String? _cachedKey;

  Future<String> _getOrCreateKey() async {
    if (_cachedKey != null) return _cachedKey!;
    var key = await _storage.read(key: _keyAlias);
    if (key == null) {
      final random = Random.secure();
      final bytes = List<int>.generate(32, (_) => random.nextInt(256));
      key = base64Encode(bytes);
      await _storage.write(key: _keyAlias, value: key);
    }
    _cachedKey = key;
    return key;
  }

  Future<String> encrypt(String plaintext) async {
    final keyStr = await _getOrCreateKey();
    final key = Key.fromBase64(keyStr);
    final iv = IV.fromSecureRandom(12);
    final encrypter = Encrypter(AES(key, mode: AESMode.gcm));
    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    return '$_v2Prefix${iv.base64}:${encrypted.base64}';
  }

  Future<String> decrypt(String encrypted) async {
    if (encrypted.startsWith(_v2Prefix)) {
      final rest = encrypted.substring(_v2Prefix.length);
      final colon = rest.indexOf(':');
      if (colon <= 0) return encrypted;
      final ivB64 = rest.substring(0, colon);
      final ctB64 = rest.substring(colon + 1);
      final keyStr = await _getOrCreateKey();
      final key = Key.fromBase64(keyStr);
      final iv = IV.fromBase64(ivB64);
      final enc = Encrypted.fromBase64(ctB64);
      final encrypter = Encrypter(AES(key, mode: AESMode.gcm));
      return encrypter.decrypt(enc, iv: iv);
    }
    return _decryptLegacy(encrypted);
  }

  Future<String> _decryptLegacy(String encrypted) async {
    final parts = encrypted.split(':');
    if (parts.length != 2) return encrypted;
    try {
      final plainBytes = base64Decode(parts[1]);
      final plaintext = utf8.decode(plainBytes);
      final key = await _getOrCreateKey();
      final keyBytes = utf8.encode(key);
      final digest = Hmac(sha256, keyBytes).convert(plainBytes);
      if (digest.toString() != parts[0]) {
        throw FormatException('legacy_hmac_mismatch');
      }
      return plaintext;
    } catch (e) {
      if (e is FormatException) rethrow;
      return encrypted;
    }
  }
}
