import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'encryption_service.dart';

class MarginalArchiveService {
  MarginalArchiveService._();
  static final MarginalArchiveService instance = MarginalArchiveService._();

  final _client = Supabase.instance.client;
  final _enc = EncryptionService();

  Future<void> save({
    required String plainBody,
    required String aiReply,
    required String mode,
    required bool inLoop,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw StateError('not_signed_in');

    final bodyEncrypted = await _enc.encrypt(plainBody);
    await _client.from('marginal_archive_entries').insert({
      'id': const Uuid().v4(),
      'user_id': user.id,
      'body_encrypted': bodyEncrypted,
      'ai_reply': aiReply.length > 2000 ? aiReply.substring(0, 2000) : aiReply,
      'mode': mode,
      'in_loop': inLoop,
    });
  }
}
