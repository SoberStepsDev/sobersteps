import 'package:flutter_test/flutter_test.dart';
import 'package:soberstepsod/services/crash_log_loop_detector.dart';

void main() {
  group('CrashLogLoopDetector', () {
    test('jaccard identical sets', () {
      final a = {'pain', 'same', 'story'};
      expect(CrashLogLoopDetector.jaccard(a, a), 1.0);
    });

    test('jaccard disjoint', () {
      final a = {'pain', 'same', 'story'};
      final b = {'x', 'y', 'z'};
      expect(CrashLogLoopDetector.jaccard(a, b), 0.0);
    });

    test('tokenize drops stopwords', () {
      final t = CrashLogLoopDetector.tokenize('the pain is very real');
      expect(t.contains('the'), false);
      expect(t.contains('pain'), true);
    });

    test('loop threshold at 3 similar prior', () {
      final a = {'pain', 'same', 'story'};
      final b = {'pain', 'same', 'story'};
      final c = {'pain', 'same', 'story'};
      final d = {'pain', 'same', 'story'};
      expect(
        CrashLogLoopDetector.isLoopThresholdReached([a, b, c], d),
        true,
      );
    });

    test('loop threshold below 3 similar', () {
      final a = {'pain', 'same', 'story'};
      final b = {'x', 'y', 'z'};
      expect(
        CrashLogLoopDetector.isLoopThresholdReached([a, b], a),
        false,
      );
    });

    test('very long input tokenizes without throw', () {
      final long = List.filled(500, 'word').join(' ');
      expect(() => CrashLogLoopDetector.tokenize(long), returnsNormally);
    });
  });
}
