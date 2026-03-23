import 'package:fintracker_app/models/category.dart';

class Budget {
  final String id;
  final TransactionCategory category;
  final double limit;
  final double spent;
  final String currencyCode;
  final DateTime startDate;
  final DateTime endDate;

  Budget({
    required this.id,
    required this.category,
    required this.limit,
    this.spent = 0,
    this.currencyCode = 'USD',
    required this.startDate,
    required this.endDate,
  });

  double get remaining => limit - spent;
  double get progress => limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
  bool get isOverBudget => spent > limit;
  bool get isNearLimit => progress >= 0.8 && !isOverBudget;

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category.index,
        'limit': limit,
        'spent': spent,
        'currencyCode': currencyCode,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
        id: json['id'],
        category: TransactionCategory.values[json['category']],
        limit: (json['limit'] as num).toDouble(),
        spent: (json['spent'] as num).toDouble(),
        currencyCode: json['currencyCode'] ?? 'USD',
        startDate: DateTime.parse(json['startDate']),
        endDate: DateTime.parse(json['endDate']),
      );

  Budget copyWith({double? spent, double? limit}) => Budget(
        id: id,
        category: category,
        limit: limit ?? this.limit,
        spent: spent ?? this.spent,
        currencyCode: currencyCode,
        startDate: startDate,
        endDate: endDate,
      );
}

