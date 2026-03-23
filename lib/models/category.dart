import 'package:flutter/material.dart';

/// Expense/Income categories with icons and colors
enum TransactionCategory {
  // Personal categories
  groceries('Groceries', Icons.shopping_cart_rounded, Color(0xFF00E5A0)),
  rent('Rent', Icons.home_rounded, Color(0xFF6C63FF)),
  utilities('Utilities', Icons.electrical_services_rounded, Color(0xFFFFB547)),
  transport('Transport', Icons.directions_car_rounded, Color(0xFF00D9FF)),
  food('Food & Dining', Icons.restaurant_rounded, Color(0xFFFF9F43)),
  entertainment('Entertainment', Icons.movie_rounded, Color(0xFFFF6B6B)),
  healthcare('Healthcare', Icons.medical_services_rounded, Color(0xFFE040FB)),
  education('Education', Icons.school_rounded, Color(0xFF448AFF)),
  shopping('Shopping', Icons.shopping_bag_rounded, Color(0xFFFF4081)),
  salary('Salary', Icons.work_rounded, Color(0xFF00E5A0)),
  freelance('Freelance', Icons.laptop_rounded, Color(0xFF00D9FF)),
  investment('Investment', Icons.trending_up_rounded, Color(0xFF6C63FF)),
  gifts('Gifts', Icons.card_giftcard_rounded, Color(0xFFFF9F43)),
  other('Other', Icons.more_horiz_rounded, Color(0xFF78909C)),

  // Business categories
  marketing('Marketing', Icons.campaign_rounded, Color(0xFFFF6B6B)),
  payroll('Payroll', Icons.people_rounded, Color(0xFF6C63FF)),
  software('Software', Icons.computer_rounded, Color(0xFF00D9FF)),
  office('Office', Icons.business_rounded, Color(0xFFFFB547)),
  travel('Business Travel', Icons.flight_rounded, Color(0xFF448AFF)),
  consulting('Consulting', Icons.handshake_rounded, Color(0xFFE040FB)),
  sales('Sales Revenue', Icons.point_of_sale_rounded, Color(0xFF00E5A0)),
  services('Services Revenue', Icons.miscellaneous_services_rounded, Color(0xFF00D9FF)),
  equipment('Equipment', Icons.build_rounded, Color(0xFF78909C)),
  insurance('Insurance', Icons.security_rounded, Color(0xFFFF4081));

  final String label;
  final IconData icon;
  final Color color;

  const TransactionCategory(this.label, this.icon, this.color);

  /// Tax classification for auto-categorization
  String get taxCategory {
    switch (this) {
      case TransactionCategory.rent:
      case TransactionCategory.utilities:
      case TransactionCategory.office:
        return 'Business Deduction - Premises';
      case TransactionCategory.marketing:
      case TransactionCategory.software:
        return 'Business Deduction - Operations';
      case TransactionCategory.payroll:
        return 'Business Deduction - Employment';
      case TransactionCategory.travel:
      case TransactionCategory.transport:
        return 'Business Deduction - Travel';
      case TransactionCategory.insurance:
        return 'Business Deduction - Insurance';
      case TransactionCategory.equipment:
        return 'Capital Expenditure';
      case TransactionCategory.salary:
      case TransactionCategory.freelance:
        return 'Taxable Income';
      case TransactionCategory.sales:
      case TransactionCategory.services:
      case TransactionCategory.consulting:
        return 'Business Income';
      case TransactionCategory.investment:
        return 'Capital Gains';
      default:
        return 'Personal Expense';
    }
  }

  bool get isBusinessCategory {
    return [
      marketing, payroll, software, office, travel,
      consulting, sales, services, equipment, insurance,
    ].contains(this);
  }
}
