import 'package:flutter/foundation.dart' show debugPrint;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/app_constants.dart';

class CrashLogRateLimitException implements Exception {}
class CrashLogAuthException implements Exception {}
class CrashLogTimeoutException implements Exception {}

class CrashLogAiService {
  CrashLogAiService._();
  static final CrashLogAiService instance = CrashLogAiService._();

  final _client = Supabase.instance.client;

  Future<String> fetchReply({
    required String text,
    required String mode,
    required bool loopMode,
  }) async {
    var session = _client.auth.currentSession;
    if (session == null) {
      try {
        await _client.auth.refreshSession();
      } catch (_) {}
      session = _client.auth.currentSession;
      if (session == null) {
        throw CrashLogAuthException();
      }
    }

    // Edge Function zwraca 401, jeśli access token jest wygasający/nieprzyjęty.
    // Dla bezpieczeństwa odświeżamy sesję, gdy token jest bliski wygaśnięcia.
    if (session.isExpired) {
      try {
        await _client.auth.refreshSession();
      } catch (_) {
        // Jeśli refresh się nie uda, polecimy dalej; Edge Function zwróci 401 i UI obsłuży błąd.
      }
      session = _client.auth.currentSession;
      if (session == null) {
        throw CrashLogAuthException();
      }
    }
    final accessToken = session.accessToken;

    try {
      final res = await _client.functions.invoke(
        'crash-log-feedback',
        headers: {
          // Force the user's JWT; relying on the Functions client's defaults
          // seems to result in 401s in this project.
          'Authorization': 'Bearer $accessToken',
        },
        body: {
          'text': text,
          'mode': mode,
          'loop_mode': loopMode,
        },
      ).timeout(
        const Duration(seconds: 45),
        onTimeout: () => throw CrashLogTimeoutException(),
      );

      if (res.status != 200) {
        throw StateError('edge_${res.status}');
      }
      final data = res.data as Map<String, dynamic>?;
      final reply = data?['reply'] as String?;
      if (reply == null || reply.isEmpty) {
        throw StateError('empty_reply');
      }
      return reply;
    } on CrashLogTimeoutException {
      debugPrint('[CrashLogAiService] Edge Function timeout (45s)');
      throw CrashLogTimeoutException();
    } on FunctionException catch (e) {
      if (e.status == 429) throw CrashLogRateLimitException();
      if (e.status == 401) {
        // details should contain our JSON body from the Edge Function.
        debugPrint('[CrashLogAiService] 401 details: ${e.details}');
        throw CrashLogAuthException();
      }
      throw StateError('edge_${e.status}');
    }
  }

  Future<String> callClaudeAi({required String text}) async {
    if (AppConstants.anthropicApiKey.isEmpty) {
      throw StateError('anthropic_key_missing');
    }

    try {
      final res = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': AppConstants.anthropicApiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': 'claude-opus-4-6',
          'max_tokens': 500,
          'system': 'Jesteś wspierającym asystentem dla osób walczących z uzależnieniem. '
              'Odpowiedz krótko (2-3 zdania), empatycznie i konstruktywnie. '
              'Preferuj ton motywacyjny i łagodny.',
          'messages': [
            {
              'role': 'user',
              'content': text,
            }
          ],
        }),
      ).timeout(const Duration(seconds: 30));

      if (res.statusCode != 200) {
        throw StateError('claude_error_${res.statusCode}');
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final content = data['content'] as List<dynamic>?;
      if (content == null || content.isEmpty) {
        throw StateError('claude_empty_response');
      }
      final textContent = (content[0] as Map<String, dynamic>)['text'] as String?;
      if (textContent == null || textContent.isEmpty) {
        throw StateError('claude_no_text');
      }
      return textContent;
    } catch (e) {
      debugPrint('[CrashLogAiService.callClaudeAi] Error: $e');
      rethrow;
    }
  }
}
