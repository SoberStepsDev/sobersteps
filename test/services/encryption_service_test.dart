import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:soberstepsod/services/encryption_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('encrypt produces a non-empty ciphertext different from plaintext', () async {
    final svc = EncryptionService();
    const plaintext = 'Hello, sobriety!';
    final cipher = await svc.encrypt(plaintext);
    expect(cipher, isNotEmpty);
    expect(cipher, isNot(equals(plaintext)));
    expect(cipher.contains(':'), isTrue);
  });

  test('decrypt(encrypt(x)) == x round-trip', () async {
    final svc = EncryptionService();
    const plaintext = 'Journal entry: feeling hopeful today.';
    final cipher = await svc.encrypt(plaintext);
    final recovered = await svc.decrypt(cipher);
    expect(recovered, equals(plaintext));
  });

  test('two encryptions of same plaintext produce different ciphertexts (IV randomness)', () async {
    final svc = EncryptionService();
    const plaintext = 'Same text';
    final c1 = await svc.encrypt(plaintext);
    final c2 = await svc.encrypt(plaintext);
    expect(c1, isNot(equals(c2)));
    // Both must still decrypt correctly.
    expect(await svc.decrypt(c1), equals(plaintext));
    expect(await svc.decrypt(c2), equals(plaintext));
  });

  test('decrypt handles legacy base64-only format without throwing', () async {
    final svc = EncryptionService();
    // Legacy format: <64-char hex hmac>:<base64(plaintext)>
    const legacyPlain = 'old data';
    final fakeHmac = 'a' * 64;
    final legacyCipher = '$fakeHmac:${base64Encode(utf8.encode(legacyPlain))}';
    final result = await svc.decrypt(legacyCipher);
    expect(result, equals(legacyPlain));
  });

  test('decrypt returns input unchanged when format is unrecognised', () async {
    final svc = EncryptionService();
    const garbage = 'notencryptedatall';
    final result = await svc.decrypt(garbage);
    expect(result, equals(garbage));
  });

  test('encrypt empty string round-trips correctly', () async {
    final svc = EncryptionService();
    const plaintext = '';
    final cipher = await svc.encrypt(plaintext);
    final recovered = await svc.decrypt(cipher);
    expect(recovered, equals(plaintext));
  });

  test('encrypt unicode content round-trips correctly', () async {
    final svc = EncryptionService();
    const plaintext = 'Dziś czuję się dobrze 😊 — день 30';
    final cipher = await svc.encrypt(plaintext);
    final recovered = await svc.decrypt(cipher);
    expect(recovered, equals(plaintext));
  });
}
