import '../../features/health/models/health_log.dart';

enum HealthAlertSeverity { info, warning, danger }

class HealthAlert {
  final String title;
  final String message;
  final HealthAlertSeverity severity;
  final String date;

  HealthAlert({
    required this.title,
    required this.message,
    required this.severity,
    required this.date,
  });
}

class HealthRuleEngine {
  /// Evaluates health logs for a bird and returns list of actionable health alerts
  static List<HealthAlert> evaluateLogs(List<HealthLog> logs) {
    List<HealthAlert> alerts = [];
    if (logs.isEmpty) return alerts;

    // Sort logs ascending by date
    final sortedLogs = List<HealthLog>.from(logs)..sort((a, b) => a.date.compareTo(b.date));

    // Rule 1: Weight Drop > 10% in 7 days
    final logsWithWeight = sortedLogs.where((l) => l.weight != null && l.weight! > 0).toList();
    if (logsWithWeight.length >= 2) {
      final latest = logsWithWeight.last;
      // Find oldest weight log within 7 days
      final latestDate = DateTime.tryParse(latest.date) ?? DateTime.now();
      final sevenDaysAgo = latestDate.subtract(const Duration(days: 7));

      final baselineLogs = logsWithWeight.where((l) {
        final d = DateTime.tryParse(l.date);
        return d != null && d.isAfter(sevenDaysAgo.subtract(const Duration(days: 1))) && d.isBefore(latestDate);
      }).toList();

      if (baselineLogs.isNotEmpty) {
        final baselineWeight = baselineLogs.first.weight!;
        final currentWeight = latest.weight!;

        final dropPercent = ((baselineWeight - currentWeight) / baselineWeight) * 100;
        if (dropPercent >= 10.0) {
          alerts.add(HealthAlert(
            title: 'Sudden weight loss warning',
            message: 'Weight dropped ${dropPercent.toStringAsFixed(1)}% (from ${baselineWeight.toStringAsFixed(1)}g to ${currentWeight.toStringAsFixed(1)}g) within 7 days. Monitor closely and contact a vet.',
            severity: HealthAlertSeverity.danger,
            date: latest.date,
          ));
        } else if (dropPercent >= 5.0) {
          alerts.add(HealthAlert(
            title: 'Weight loss reminder',
            message: 'Weight dropped slightly by ${dropPercent.toStringAsFixed(1)}% over the past 7 days.',
            severity: HealthAlertSeverity.warning,
            date: latest.date,
          ));
        }
      }
    }

    // Rule 2: Consecutive Poor Appetite
    if (sortedLogs.length >= 2) {
      final recentLogs = sortedLogs.sublist(sortedLogs.length - 2);
      if (recentLogs.every((l) => l.appetite.toLowerCase() == 'poor' || l.appetite.toLowerCase() == 'kém')) {
        alerts.add(HealthAlert(
          title: 'Poor appetite continues',
          message: 'Poor appetite was recorded in 2 logs in a row. Check the food and the bird’s energy.',
          severity: HealthAlertSeverity.warning,
          date: recentLogs.last.date,
        ));
      }
    }

    // Rule 3: Abnormal Droppings
    if (sortedLogs.isNotEmpty) {
      final latest = sortedLogs.last;
      if (latest.droppings.toLowerCase() == 'abnormal' || latest.droppings.toLowerCase() == 'bất thường') {
        alerts.add(HealthAlert(
          title: 'Abnormal droppings',
          message: 'Droppings were recorded as abnormal on ${latest.date}. Clean the tray and check fresh food.',
          severity: HealthAlertSeverity.warning,
          date: latest.date,
        ));
      }
    }

    return alerts;
  }
}
