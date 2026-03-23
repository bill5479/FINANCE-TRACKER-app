import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:fintracker_app/models/budget.dart';
import 'package:fintracker_app/models/category.dart';
import 'package:fintracker_app/services/storage_service.dart';

class BudgetProvider extends ChangeNotifier {
  List<Budget> _budgets = [];
  final _uuid = Uuid();

  List<Budget> get budgets => List.unmodifiable(_budgets);

  BudgetProvider() {
    _loadBudgets();
    _seedDemoData();
  }

  void _seedDemoData() {
    if (_budgets.isNotEmpty) return;
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);

    _budgets = [
      Budget(id: _uuid.v4(), category: TransactionCategory.groceries, limit: 400, spent: 127.50, startDate: monthStart, endDate: monthEnd),
      Budget(id: _uuid.v4(), category: TransactionCategory.rent, limit: 1500, spent: 1500, startDate: monthStart, endDate: monthEnd),
      Budget(id: _uuid.v4(), category: TransactionCategory.entertainment, limit: 100, spent: 15.99, startDate: monthStart, endDate: monthEnd),
      Budget(id: _uuid.v4(), category: TransactionCategory.transport, limit: 200, spent: 42.30, startDate: monthStart, endDate: monthEnd),
      Budget(id: _uuid.v4(), category: TransactionCategory.food, limit: 300, spent: 78.50, startDate: monthStart, endDate: monthEnd),
      Budget(id: _uuid.v4(), category: TransactionCategory.healthcare, limit: 150, spent: 49.99, startDate: monthStart, endDate: monthEnd),
    ];
    _saveBudgets();
    notifyListeners();
  }

  Future<void> _loadBudgets() async {
    final data = await StorageService.instance.load('budgets');
    if (data != null && data is List) {
      _budgets = data.map((j) => Budget.fromJson(j)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveBudgets() async {
    await StorageService.instance.save('budgets', _budgets.map((b) => b.toJson()).toList());
  }

  Future<void> addBudget(Budget budget) async {
    _budgets.add(budget);
    await _saveBudgets();
    notifyListeners();
  }

  Future<void> removeBudget(String id) async {
    _budgets.removeWhere((b) => b.id == id);
    await _saveBudgets();
    notifyListeners();
  }

  Future<void> updateSpent(TransactionCategory category, double amount) async {
    final index = _budgets.indexWhere((b) => b.category == category);
    if (index != -1) {
      _budgets[index] = _budgets[index].copyWith(spent: _budgets[index].spent + amount);
      await _saveBudgets();
      notifyListeners();
    }
  }

  Budget? getBudget(TransactionCategory category) {
    try {
      return _budgets.firstWhere((b) => b.category == category);
    } catch (_) {
      return null;
    }
  }

  double get totalBudgetLimit => _budgets.fold(0, (sum, b) => sum + b.limit);
  double get totalBudgetSpent => _budgets.fold(0, (sum, b) => sum + b.spent);
  double get overallProgress => totalBudgetLimit > 0 ? (totalBudgetSpent / totalBudgetLimit).clamp(0.0, 1.0) : 0.0;
}

