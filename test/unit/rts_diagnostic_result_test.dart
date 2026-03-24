import 'package:flutter_test/flutter_test.dart';
import 'package:soberstepsod/models/rts_diagnostic.dart';

void main() {
  test('RtsDiagnosticResult roundtrip', () {
    const r = RtsDiagnosticResult(
      score: 12,
      profile: RtsDiagnosticProfile.innerCritic,
    );
    final j = r.toJson();
    final back = RtsDiagnosticResult.fromJson(j);
    expect(back.score, 12);
    expect(back.profile, RtsDiagnosticProfile.innerCritic);
  });

  test('fromJson maps unknown profile key via score', () {
    final r = RtsDiagnosticResult.fromJson({'score': 25, 'profile': 'unknown'});
    expect(r.profile, RtsDiagnosticProfile.survivalMode);
  });
}
