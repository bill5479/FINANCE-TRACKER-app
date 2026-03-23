import 'package:fintracker_app/models/category.dart';

class TaxClassifier {
  const TaxClassifier._();

  static String classify({
    required String title,
    required TransactionCategory category,
    required bool isBusiness,
  }) {
    final normalized = title.toLowerCase();

    if (normalized.contains('tax')) {
      return 'Tax Payment';
    }
    if (normalized.contains('invoice') || normalized.contains('client')) {
      return 'Business Income';
    }
    if (normalized.contains('rent') && isBusiness) {
      return 'Business Deduction - Premises';
    }
    if (normalized.contains('travel') || normalized.contains('flight')) {
      return 'Business Deduction - Travel';
    }

    return category.taxCategory;
  }
}
