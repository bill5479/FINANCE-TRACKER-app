import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:fintracker_app/models/category.dart';
import 'package:fintracker_app/models/transaction.dart';
import 'package:fintracker_app/services/recurring_engine.dart';
import 'package:fintracker_app/services/storage_service.dart';

class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  final Uuid _uuid = const Uuid();

  List<Transaction> get transactions => List.unmodifiable(_transactions);

  List<Transaction> get personalTransactions =>
      _transactions.where((transaction) => !transaction.isBusiness).toList();

  List<Transaction> get businessTransactions =>
      _transactions.where((transaction) => transaction.isBusiness).toList();

  double get totalIncome => _transactions
      .where((transaction) => transaction.type == TransactionType.income)
      .fold(0.0, (sum, transaction) => sum + transaction.amount);

  double get totalExpense => _transactions
      .where((transaction) => transaction.type == TransactionType.expense)
      .fold(0.0, (sum, transaction) => sum + transaction.amount);

  double get personalIncome => personalTransactions
      .where((transaction) => transaction.type == TransactionType.income)
      .fold(0.0, (sum, transaction) => sum + transaction.amount);

  double get personalExpense => personalTransactions
      .where((transaction) => transaction.type == TransactionType.expense)
      .fold(0.0, (sum, transaction) => sum + transaction.amount);

  double get personalBalance => personalIncome - personalExpense;

  double get businessIncome => businessTransactions
      .where((transaction) => transaction.type == TransactionType.income)
      .fold(0.0, (sum, transaction) => sum + transaction.amount);

  double get businessExpense => businessTransactions
      .where((transaction) => transaction.type == TransactionType.expense)
      .fold(0.0, (sum, transaction) => sum + transaction.amount);

  double get businessProfit => businessIncome - businessExpense;

  TransactionProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadTransactions();
    if (_transactions.isEmpty) {
      await _seedDemoData();
    }
    await _materializeRecurringTransactions();
    _sortTransactions();
    notifyListeners();
  }

  Future<void> _seedDemoData() async {
    final now = DateTime.now();
    _transactions = [
      Transaction(
        id: _uuid.v4(),
        title: 'Monthly Salary',
        amount: 5200,
        type: TransactionType.income,
        category: TransactionCategory.salary,
        date: now.subtract(const Duration(days: 32)),
        isRecurring: true,
        isRecurringTemplate: true,
        recurrence: RecurrenceInterval.monthly,
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Apartment Rent',
        amount: 1500,
        type: TransactionType.expense,
        category: TransactionCategory.rent,
        date: now.subtract(const Duration(days: 35)),
        isRecurring: true,
        isRecurringTemplate: true,
        recurrence: RecurrenceInterval.monthly,
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Whole Foods Groceries',
        amount: 127.50,
        type: TransactionType.expense,
        category: TransactionCategory.groceries,
        date: now.subtract(const Duration(days: 3)),
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Netflix Subscription',
        amount: 15.99,
        type: TransactionType.expense,
        category: TransactionCategory.entertainment,
        date: now.subtract(const Duration(days: 38)),
        isRecurring: true,
        isRecurringTemplate: true,
        recurrence: RecurrenceInterval.monthly,
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Uber Rides',
        amount: 42.30,
        type: TransactionType.expense,
        category: TransactionCategory.transport,
        date: now.subtract(const Duration(days: 4)),
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Freelance Project',
        amount: 850,
        type: TransactionType.income,
        category: TransactionCategory.freelance,
        date: now.subtract(const Duration(days: 7)),
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Gym Membership',
        amount: 49.99,
        type: TransactionType.expense,
        category: TransactionCategory.healthcare,
        date: now.subtract(const Duration(days: 40)),
        isRecurring: true,
        isRecurringTemplate: true,
        recurrence: RecurrenceInterval.monthly,
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Restaurant Dinner',
        amount: 78.50,
        type: TransactionType.expense,
        category: TransactionCategory.food,
        date: now.subtract(const Duration(days: 6)),
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Google Ads Campaign',
        amount: 500,
        type: TransactionType.expense,
        category: TransactionCategory.marketing,
        date: now.subtract(const Duration(days: 2)),
        isBusiness: true,
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Employee Payroll',
        amount: 8500,
        type: TransactionType.expense,
        category: TransactionCategory.payroll,
        date: now.subtract(const Duration(days: 33)),
        isBusiness: true,
        isRecurring: true,
        isRecurringTemplate: true,
        recurrence: RecurrenceInterval.monthly,
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Client Project Payment',
        amount: 15000,
        type: TransactionType.income,
        category: TransactionCategory.sales,
        date: now.subtract(const Duration(days: 3)),
        isBusiness: true,
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Consulting Fee',
        amount: 3200,
        type: TransactionType.income,
        category: TransactionCategory.consulting,
        date: now.subtract(const Duration(days: 5)),
        isBusiness: true,
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Adobe Suite License',
        amount: 79.99,
        type: TransactionType.expense,
        category: TransactionCategory.software,
        date: now.subtract(const Duration(days: 36)),
        isBusiness: true,
        isRecurring: true,
        isRecurringTemplate: true,
        recurrence: RecurrenceInterval.monthly,
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Office Rent',
        amount: 2000,
        type: TransactionType.expense,
        category: TransactionCategory.office,
        date: now.subtract(const Duration(days: 34)),
        isBusiness: true,
        isRecurring: true,
        isRecurringTemplate: true,
        recurrence: RecurrenceInterval.monthly,
      ),
    ];
    _sortTransactions();
    await _saveTransactions();
  }

  Future<void> _loadTransactions() async {
    final data = await StorageService.instance.load('transactions');
    if (data != null && data is List) {
      _transactions = data.map((json) => Transaction.fromJson(json)).toList();
    }
  }

  Future<void> _saveTransactions() async {
    await StorageService.instance.save(
      'transactions',
      _transactions.map((transaction) => transaction.toJson()).toList(),
    );
  }

  Future<void> _materializeRecurringTransactions() async {
    final generated = RecurringEngine.materializeMissed(_transactions, _uuid.v4);
    if (generated.isEmpty) {
      return;
    }

    _transactions.addAll(generated);
    _sortTransactions();
    await _saveTransactions();
  }

  Future<void> addTransaction(Transaction transaction) async {
    _transactions.add(transaction);
    _sortTransactions();
    await _saveTransactions();
    notifyListeners();
  }

  Future<void> removeTransaction(String id) async {
    _transactions.removeWhere((transaction) => transaction.id == id);
    await _saveTransactions();
    notifyListeners();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final index = _transactions.indexWhere((item) => item.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
      _sortTransactions();
      await _saveTransactions();
      notifyListeners();
    }
  }

  List<Transaction> getByCategory(TransactionCategory category) =>
      _transactions.where((transaction) => transaction.category == category).toList();

  List<Transaction> getByDateRange(DateTime start, DateTime end) => _transactions
      .where(
        (transaction) =>
            transaction.date.isAfter(start.subtract(const Duration(days: 1))) &&
            transaction.date.isBefore(end.add(const Duration(days: 1))),
      )
      .toList();

  Map<TransactionCategory, double> getExpenseByCategory({bool business = false}) {
    final filtered = (business ? businessTransactions : personalTransactions)
        .where((transaction) => transaction.type == TransactionType.expense);
    final result = <TransactionCategory, double>{};
    for (final transaction in filtered) {
      result[transaction.category] =
          (result[transaction.category] ?? 0) + transaction.amount;
    }
    return result;
  }

  List<MonthlyPnL> getMonthlyPnL({bool business = false}) {
    final now = DateTime.now();
    final result = <MonthlyPnL>[];
    for (var i = 5; i >= 0; i--) {
      final monthStart = DateTime(now.year, now.month - i, 1);
      final monthEnd = DateTime(now.year, now.month - i + 1, 0);
      final monthTransactions = (business ? businessTransactions : personalTransactions).where(
        (transaction) =>
            transaction.date.isAfter(monthStart.subtract(const Duration(days: 1))) &&
            transaction.date.isBefore(monthEnd.add(const Duration(days: 1))),
      );
      final income = monthTransactions
          .where((transaction) => transaction.type == TransactionType.income)
          .fold(0.0, (sum, transaction) => sum + transaction.amount);
      final expense = monthTransactions
          .where((transaction) => transaction.type == TransactionType.expense)
          .fold(0.0, (sum, transaction) => sum + transaction.amount);
      result.add(MonthlyPnL(month: monthStart, income: income, expense: expense));
    }
    return result;
  }

  void _sortTransactions() {
    _transactions.sort((a, b) => b.date.compareTo(a.date));
  }
}

class MonthlyPnL {
  final DateTime month;
  final double income;
  final double expense;

  double get profit => income - expense;

  MonthlyPnL({
    required this.month,
    required this.income,
    required this.expense,
  });
}
