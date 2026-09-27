import 'package:flutter_test/flutter_test.dart';
import 'package:bird_care/core/utils/health_rule_engine.dart';
import 'package:bird_care/features/health/models/health_log.dart';

void main() {
  group('HealthRuleEngine Tests', () {
    test('Should trigger danger alert when weight loss > 10% in 7 days', () {
      final now = DateTime.now();
      final logs = [
        HealthLog(
          id: 'log1',
          birdId: 'bird1',
          date: now.subtract(const Duration(days: 5)).toString().split(' ')[0],
          weight: 40.0,
          createdAt: now.toIso8601String(),
        ),
        HealthLog(
          id: 'log2',
          birdId: 'bird1',
          date: now.toString().split(' ')[0],
          weight: 35.0, // 5g drop out of 40g = 12.5% drop (>10%)
          createdAt: now.toIso8601String(),
        ),
      ];

      final alerts = HealthRuleEngine.evaluateLogs(logs);

      expect(alerts.isNotEmpty, true);
      expect(alerts.first.severity, HealthAlertSeverity.danger);
      expect(alerts.first.title.contains('Cảnh báo'), true);
    });

    test('Should trigger warning alert when appetite is poor for 2 consecutive logs', () {
      final now = DateTime.now();
      final logs = [
        HealthLog(
          id: 'log1',
          birdId: 'bird1',
          date: now.subtract(const Duration(days: 1)).toString().split(' ')[0],
          appetite: 'Poor',
          createdAt: now.toIso8601String(),
        ),
        HealthLog(
          id: 'log2',
          birdId: 'bird1',
          date: now.toString().split(' ')[0],
          appetite: 'Poor',
          createdAt: now.toIso8601String(),
        ),
      ];

      final alerts = HealthRuleEngine.evaluateLogs(logs);

      expect(alerts.any((a) => a.title.contains('Ăn uống kém')), true);
    });
  });
}
