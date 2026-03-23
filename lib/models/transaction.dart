import 'package:fintracker_app/models/category.dart';

enum TransactionType { income, expense }

enum RecurrenceInterval { none, daily, weekly, biweekly, monthly, quarterly, yearly }

class Transaction {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final TransactionCategory category;
  final DateTime date;
  final String currencyCode;
  final String? notes;
  final bool isRecurring;
  final bool isRecurringTemplate;
  final String? recurringSourceId;
  final RecurrenceInterval recurrence;
  final bool isBusiness;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.currencyCode = 'USD',
    this.notes,
    this.isRecurring = false,
    bool? isRecurringTemplate,
    this.recurringSourceId,
    this.recurrence = RecurrenceInterval.none,
    this.isBusiness = false,
    DateTime? createdAt,
  })  : isRecurringTemplate = isRecurringTemplate ?? (isRecurring && recurringSourceId == null),
        createdAt = createdAt ?? DateTime.now();

  bool get isGeneratedRecurring => recurringSourceId != null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'type': type.index,
        'category': category.index,
        'date': date.toIso8601String(),
        'currencyCode': currencyCode,
        'notes': notes,
        'isRecurring': isRecurring,
        'isRecurringTemplate': isRecurringTemplate,
        'recurringSourceId': recurringSourceId,
        'recurrence': recurrence.index,
        'isBusiness': isBusiness,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'],
        title: json['title'],
        amount: (json['amount'] as num).toDouble(),
        type: TransactionType.values[json['type']],
        category: TransactionCategory.values[json['category']],
        date: DateTime.parse(json['date']),
        currencyCode: json['currencyCode'] ?? 'USD',
        notes: json['notes'],
        isRecurring: json['isRecurring'] ?? false,
        isRecurringTemplate: json['isRecurringTemplate'] ?? (json['isRecurring'] ?? false),
        recurringSourceId: json['recurringSourceId'],
        recurrence: RecurrenceInterval.values[json['recurrence'] ?? 0],
        isBusiness: json['isBusiness'] ?? false,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.parse(json['date']),
      );

  Transaction copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    TransactionCategory? category,
    DateTime? date,
    String? currencyCode,
    String? notes,
    bool? isRecurring,
    bool? isRecurringTemplate,
    String? recurringSourceId,
    RecurrenceInterval? recurrence,
    bool? isBusiness,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      currencyCode: currencyCode ?? this.currencyCode,
      notes: notes ?? this.notes,
      isRecurring: isRecurring ?? this.isRecurring,
      isRecurringTemplate: isRecurringTemplate ?? this.isRecurringTemplate,
      recurringSourceId: recurringSourceId ?? this.recurringSourceId,
      recurrence: recurrence ?? this.recurrence,
      isBusiness: isBusiness ?? this.isBusiness,
      createdAt: createdAt,
    );
  }
}
