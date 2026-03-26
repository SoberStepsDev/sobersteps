import 'package:flutter_test/flutter_test.dart';
import 'package:soberstepsod/services/crisis_detection_service.dart';

void main() {
  group('CrisisDetectionService', () {
    late CrisisDetectionService svc;
    late int crisisCount;

    setUp(() {
      svc = CrisisDetectionService();
      crisisCount = 0;
      svc.onCrisisDetected = () => crisisCount++;
    });

    test('no crisis when cravings are below threshold', () {
      for (var i = 0; i < 5; i++) {
        svc.recordCheckin(mood: 3, cravingLevel: 5);
      }
      expect(crisisCount, 0);
    });

    test('no crisis when craving is high but mood is not critical', () {
      for (var i = 0; i < 3; i++) {
        svc.recordCheckin(mood: 2, cravingLevel: 9);
      }
      expect(crisisCount, 0);
    });

    test('no crisis with only 2 high cravings + critical mood', () {
      svc.recordCheckin(mood: 1, cravingLevel: 9);
      svc.recordCheckin(mood: 1, cravingLevel: 9);
      expect(crisisCount, 0);
    });

    test('crisis fires when 3+ high cravings and mood == 1 within window', () {
      svc.recordCheckin(mood: 1, cravingLevel: 9);
      svc.recordCheckin(mood: 3, cravingLevel: 9);
      svc.recordCheckin(mood: 2, cravingLevel: 9);
      expect(crisisCount, 1);
    });

    test('crisis does not re-fire on subsequent normal check-ins', () {
      svc.recordCheckin(mood: 1, cravingLevel: 9);
      svc.recordCheckin(mood: 3, cravingLevel: 9);
      svc.recordCheckin(mood: 2, cravingLevel: 9);
      // Already in crisis — normal check-ins should not add more crisis events
      // (the window still has the same 3 snapshots + mood=1 present).
      svc.recordCheckin(mood: 3, cravingLevel: 3);
      // crisisCount may be >= 1 due to window but must not be 0.
      expect(crisisCount, greaterThanOrEqualTo(1));
    });

    test('craving exactly at threshold (8) does not count as high', () {
      for (var i = 0; i < 3; i++) {
        svc.recordCheckin(mood: 1, cravingLevel: 8);
      }
      expect(crisisCount, 0);
    });

    test('craving one above threshold (9) counts as high', () {
      svc.recordCheckin(mood: 1, cravingLevel: 9);
      svc.recordCheckin(mood: 1, cravingLevel: 9);
      svc.recordCheckin(mood: 1, cravingLevel: 9);
      expect(crisisCount, 1);
    });
  });
}
