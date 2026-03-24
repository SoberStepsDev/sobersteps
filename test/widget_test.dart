import 'package:flutter_test/flutter_test.dart';
import 'package:soberstepsod/models/rts_diagnostic.dart';

void main() {
  test('RtsDiagnostic score 10 answers A=0..D=3', () {
    expect(RtsDiagnostic.questions.length, 10);
    expect(RtsDiagnostic.scoreAnswers([0, 0, 0, 0, 0, 0, 0, 0, 0, 0]), 0);
    expect(RtsDiagnostic.scoreAnswers([3, 3, 3, 3, 3, 3, 3, 3, 3, 3]), 30);
    expect(RtsDiagnostic.profileForScore(0), RtsDiagnosticProfile.returningToYourself);
    expect(RtsDiagnostic.profileForScore(30), RtsDiagnosticProfile.survivalMode);
  });
}
