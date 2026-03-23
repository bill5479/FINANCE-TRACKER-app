import 'package:fintracker_app/models/transaction.dart';

class RecurringEngine {
  const RecurringEngine._();

  static List<Transaction> materializeMissed(
    List<Transaction> transactions,
    String Function() generateId,
  ) {
    final generated = <Transaction>[];
    final existing = List<Transaction>.from(transactions);

    for (final template in transactions.where(
      (transaction) => transaction.isRecurring && transaction.isRecurringTemplate,
    )) {
      if (template.recurrence == RecurrenceInterval.none) {
        continue;
      }

      var nextDate = nextOccurrence(template.date, template.recurrence);
      while (!nextDate.isAfter(DateTime.now())) {
        final alreadyExists = existing.any(
          (transaction) =>
              transaction.recurringSourceId == template.id &&
              _sameCalendarDay(transaction.date, nextDate),
        );

        if (!alreadyExists) {
          final entry = template.copyWith(
            id: generateId(),
            date: nextDate,
            isRecurring: true,
            isRecurringTemplate: false,
            recurringSourceId: template.id,
          );
          generated.add(entry);
          existing.add(entry);
        }

        nextDate = nextOccurrence(nextDate, template.recurrence);
      }
    }

    return generated;
  }

  static DateTime nextOccurrence(DateTime from, RecurrenceInterval interval) {
    switch (interval) {
      case RecurrenceInterval.daily:
        return from.add(const Duration(days: 1));
      case RecurrenceInterval.weekly:
        return from.add(const Duration(days: 7));
      case RecurrenceInterval.biweekly:
        return from.add(const Duration(days: 14));
      case RecurrenceInterval.monthly:
        return DateTime(from.year, from.month + 1, from.day);
      case RecurrenceInterval.quarterly:
        return DateTime(from.year, from.month + 3, from.day);
      case RecurrenceInterval.yearly:
        return DateTime(from.year + 1, from.month, from.day);
      case RecurrenceInterval.none:
        return from;
    }
  }

  static bool _sameCalendarDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
