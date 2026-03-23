import 'package:flutter/foundation.dart';

/// Local notification facade used by budget and invoice flows.
///
/// The app is local-first in v1, so this service keeps a simple scheduling API
/// that can be backed by flutter_local_notifications on-device without changing
/// the rest of the app surface.
class NotificationService {
  static NotificationService? _instance;
  NotificationService._();
  static NotificationService get instance => _instance ??= NotificationService._();

  bool _initialized = false;
  bool _enabled = true;

  bool get isEnabled => _enabled;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
  }

  Future<void> scheduleBillReminder({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (!_enabled) return;
    debugPrint('Notification scheduled [$id]: $title at $scheduledDate :: $body');
  }

  Future<void> showBudgetAlert({
    required String categoryName,
    required double percentUsed,
  }) async {
    if (!_enabled) return;
    final title = 'Budget Alert: $categoryName';
    final body = percentUsed >= 1.0
        ? 'You have exceeded your $categoryName budget.'
        : 'You have used ${(percentUsed * 100).toStringAsFixed(0)}% of your $categoryName budget.';
    debugPrint('Budget notification: $title :: $body');
  }

  Future<void> cancelNotification(String id) async {
    debugPrint('Notification cancelled: $id');
  }

  Future<void> cancelAll() async {
    debugPrint('All notifications cancelled');
  }
}

