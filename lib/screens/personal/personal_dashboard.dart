import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:fintracker_app/models/category.dart';
import 'package:fintracker_app/models/transaction.dart';
import 'package:fintracker_app/providers/auth_provider.dart';
import 'package:fintracker_app/providers/budget_provider.dart';
import 'package:fintracker_app/providers/theme_provider.dart';
import 'package:fintracker_app/providers/transaction_provider.dart';
import 'package:fintracker_app/screens/personal/add_transaction_sheet.dart';
import 'package:fintracker_app/screens/personal/budget_screen.dart';
import 'package:fintracker_app/screens/personal/transaction_history.dart';
import 'package:fintracker_app/services/currency_service.dart';
import 'package:fintracker_app/theme/app_theme.dart';
import 'package:fintracker_app/theme/glass_tokens.dart';
import 'package:fintracker_app/widgets/glass_app_bar.dart';
import 'package:fintracker_app/widgets/glass_button.dart';
import 'package:fintracker_app/widgets/glass_card.dart';
import 'package:fintracker_app/widgets/glass_progress_bar.dart';

class PersonalDashboard extends StatelessWidget {
  const PersonalDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = context.watch<TransactionProvider>();
    final budgets = context.watch<BudgetProvider>();
    final auth = context.watch<AuthProvider>();
    final currency = context.watch<ThemeProvider>().currencyCode;
    final recent = transactions.personalTransactions.take(5).toList();
    final spendingByCategory = transactions.getExpenseByCategory();
    final topCategories = spendingByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final savingsRate = transactions.personalIncome <= 0
        ? 0.0
        : ((transactions.personalIncome - transactions.personalExpense) /
                transactions.personalIncome)
            .clamp(0.0, 1.0);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: GlassAppBar(
            title: 'Overview',
            actions: [
              if (auth.canEdit)
                GlassButton(
                  label: 'Quick Add',
                  icon: Icons.auto_awesome_rounded,
                  small: true,
                  onPressed: () => _showTypePicker(context),
                ),
              if (auth.canEdit)
                GlassButton(
                  label: 'Add Transaction',
                  icon: Icons.add_rounded,
                  small: true,
                  gradientColors: AppTheme.accentGradient,
                  onPressed: () => _showTypePicker(context),
                ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: GlassTokens.spacingMD),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 980;
                final cards = [
                  _HeroMetricCard(
                    title: 'TOTAL BALANCE',
                    amount: CurrencyService.format(
                      transactions.personalBalance,
                      currency,
                    ),
                    icon: Icons.account_balance_wallet_outlined,
                    color: AppTheme.textPrimary(context),
                  ),
                  _HeroMetricCard(
                    title: 'INCOME',
                    amount: CurrencyService.format(
                      transactions.personalIncome,
                      currency,
                    ),
                    icon: Icons.trending_up_rounded,
                    color: AppTheme.success(context),
                  ),
                  _HeroMetricCard(
                    title: 'EXPENSES',
                    amount: CurrencyService.format(
                      transactions.personalExpense,
                      currency,
                    ),
                    icon: Icons.trending_down_rounded,
                    color: AppTheme.error(context),
                  ),
                ];

                if (!wide) {
                  return Column(
                    children: [
                      for (final card in cards) ...[
                        card,
                        const SizedBox(height: GlassTokens.spacingMD),
                      ],
                    ],
                  );
                }

                return Row(
                  children: [
                    for (var index = 0; index < cards.length; index++) ...[
                      Expanded(child: cards[index]),
                      if (index != cards.length - 1)
                        const SizedBox(width: GlassTokens.spacingMD),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(GlassTokens.spacingMD),
            child: GlassCard(
              padding: const EdgeInsets.all(GlassTokens.spacingXL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.accent(context).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.account_balance_rounded,
                          color: AppTheme.accent(context),
                        ),
                      ),
                      const SizedBox(width: GlassTokens.spacingMD),
                      Expanded(
                        child: Text(
                          'EMI & Loan Tracker',
                          style: AppTheme.headlineMedium.copyWith(
                            color: AppTheme.textPrimary(context),
                          ),
                        ),
                      ),
                      if (auth.canEdit)
                        GlassButton(
                          label: 'Add Loan',
                          icon: Icons.add_rounded,
                          small: true,
                          gradientColors: AppTheme.accentGradient,
                          onPressed: () {},
                        ),
                    ],
                  ),
                  const SizedBox(height: GlassTokens.spacingXXL),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.calculate_outlined,
                          size: 56,
                          color: AppTheme.textTertiary(context),
                        ),
                        const SizedBox(height: GlassTokens.spacingMD),
                        Text(
                          'No active loans tracked.',
                          style: AppTheme.titleMedium.copyWith(
                            color: AppTheme.textSecondary(context),
                          ),
                        ),
                        const SizedBox(height: GlassTokens.spacingSM),
                        Text(
                          'Keep liabilities quiet here so your overview stays calm and trustworthy.',
                          textAlign: TextAlign.center,
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textTertiary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: GlassTokens.spacingMD),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 1100;
                final spendingCard = GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Spending by Category',
                            style: AppTheme.headlineMedium.copyWith(
                              color: AppTheme.textPrimary(context),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const BudgetScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Budgets',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.accent(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: GlassTokens.spacingLG),
                      if (topCategories.isEmpty)
                        Text(
                          'No expenses yet. Once you start logging spending, the top categories will appear here.',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondary(context),
                          ),
                        )
                      else
                        ...topCategories.take(5).map((entry) {
                          final maxValue = topCategories.first.value;
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: GlassTokens.spacingMD,
                            ),
                            child: GlassProgressBar(
                              progress: maxValue <= 0 ? 0 : entry.value / maxValue,
                              label: entry.key.label,
                              sublabel: CurrencyService.format(entry.value, currency),
                              gradientColors: [
                                entry.key.color,
                                entry.key.color.withOpacity(0.55),
                              ],
                              height: 9,
                              showPercentage: false,
                            ),
                          );
                        }),
                    ],
                  ),
                );

                final recentCard = GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Activity',
                            style: AppTheme.headlineMedium.copyWith(
                              color: AppTheme.textPrimary(context),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const TransactionHistory(),
                                ),
                              );
                            },
                            child: Text(
                              'View all',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.accent(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: GlassTokens.spacingLG),
                      if (recent.isEmpty)
                        Text(
                          'No personal transactions yet.',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondary(context),
                          ),
                        )
                      else
                        ...recent.map(
                          (transaction) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: GlassTokens.spacingSM,
                            ),
                            child: _RecentTransactionRow(
                              transaction: transaction,
                              currency: currency,
                            ),
                          ),
                        ),
                    ],
                  ),
                );

                if (!wide) {
                  return Column(
                    children: [
                      spendingCard,
                      const SizedBox(height: GlassTokens.spacingMD),
                      recentCard,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: spendingCard),
                    const SizedBox(width: GlassTokens.spacingMD),
                    Expanded(flex: 5, child: recentCard),
                  ],
                );
              },
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(GlassTokens.spacingMD),
            child: GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Financial Insight',
                        style: AppTheme.headlineMedium.copyWith(
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'Health Score',
                            style: AppTheme.labelLarge.copyWith(
                              color: AppTheme.textTertiary(context),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.success(context),
                                width: 3,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${(savingsRate * 100).round()}',
                                style: AppTheme.titleLarge.copyWith(
                                  color: AppTheme.success(context),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: GlassTokens.spacingLG),
                  Text(
                    _insightSummary(
                      balance: transactions.personalBalance,
                      income: transactions.personalIncome,
                      expense: transactions.personalExpense,
                      currency: currency,
                    ),
                    style: AppTheme.bodyLarge.copyWith(
                      color: AppTheme.textSecondary(context),
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: GlassTokens.spacingLG),
                  Container(
                    padding: const EdgeInsets.all(GlassTokens.spacingLG),
                    decoration: BoxDecoration(
                      color: AppTheme.warning(context).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: AppTheme.warning(context).withOpacity(0.12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SMART SUGGESTIONS',
                          style: AppTheme.labelLarge.copyWith(
                            color: AppTheme.warning(context),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: GlassTokens.spacingMD),
                        ..._suggestions(
                          savingsRate: savingsRate,
                          budgets: budgets,
                          categories: topCategories,
                          currency: currency,
                        ).map(
                          (suggestion) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: GlassTokens.spacingSM,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 7),
                                  child: Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: AppTheme.warning(context),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: GlassTokens.spacingMD),
                                Expanded(
                                  child: Text(
                                    suggestion,
                                    style: AppTheme.bodyLarge.copyWith(
                                      color: AppTheme.textSecondary(context),
                                      height: 1.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: GlassTokens.spacingXXL),
        ),
      ],
    );
  }

  static void _showTypePicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(GlassTokens.spacingLG),
          decoration: BoxDecoration(
            color: AppTheme.bg(context),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(32),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TypePickerTile(
                  icon: Icons.arrow_upward_rounded,
                  title: 'Log income',
                  subtitle: 'Salary, freelance, transfers, and other credits',
                  color: AppTheme.success(context),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showSheet(context, TransactionType.income);
                  },
                ),
                const SizedBox(height: GlassTokens.spacingSM),
                _TypePickerTile(
                  icon: Icons.arrow_downward_rounded,
                  title: 'Log expense',
                  subtitle: 'Groceries, rent, bills, subscriptions, and more',
                  color: AppTheme.error(context),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showSheet(context, TransactionType.expense);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void _showSheet(BuildContext context, TransactionType type) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTransactionSheet(type: type, isBusiness: false),
    );
  }

  static String _insightSummary({
    required double balance,
    required double income,
    required double expense,
    required String currency,
  }) {
    final net = income - expense;
    final tone = net >= 0 ? 'steady and resilient' : 'under pressure';
    return 'With ${CurrencyService.format(balance, currency)} on hand and ${CurrencyService.format(expense, currency)} in tracked spending, your personal finances look $tone. The goal here is clarity over noise, so the dashboard keeps attention on balance, habit quality, and the few categories that matter most.';
  }

  static List<String> _suggestions({
    required double savingsRate,
    required BudgetProvider budgets,
    required List<MapEntry<TransactionCategory, double>> categories,
    required String currency,
  }) {
    final items = <String>[];
    if (savingsRate >= 0.35) {
      items.add('Your savings rate is strong. Consider moving a fixed slice of monthly surplus into a high-priority goal or long-term investment bucket so the cushion compounds quietly.');
    } else {
      items.add('Your savings rate would benefit from one small structural change. Tightening just the highest-spend category can create breathing room without making the whole budget feel restrictive.');
    }

    if (budgets.budgets.any((budget) => budget.progress >= 0.8)) {
      final atRisk = budgets.budgets.firstWhere((budget) => budget.progress >= 0.8);
      items.add('The ${atRisk.category.label.toLowerCase()} budget is nearing its limit. A mid-cycle check now is likely more effective than a hard reset at month-end.');
    }

    if (categories.isNotEmpty) {
      final category = categories.first;
      items.add('${category.key.label} is currently your largest expense area at ${CurrencyService.format(category.value, currency)}. If you want one place to review this week, start there.');
    }

    return items.take(3).toList();
  }
}

class _HeroMetricCard extends StatelessWidget {
  const _HeroMetricCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  final String title;
  final String amount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      height: 170,
      padding: const EdgeInsets.all(GlassTokens.spacingXL),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            bottom: -6,
            child: Icon(
              icon,
              size: 86,
              color: color.withOpacity(0.12),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.labelLarge.copyWith(
                  color: AppTheme.textSecondary(context),
                  letterSpacing: 1.1,
                ),
              ),
              const Spacer(),
              Text(
                amount,
                style: AppTheme.amountLarge.copyWith(color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentTransactionRow extends StatelessWidget {
  const _RecentTransactionRow({
    required this.transaction,
    required this.currency,
  });

  final Transaction transaction;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GlassTokens.spacingMD,
        vertical: GlassTokens.spacingSM,
      ),
      decoration: BoxDecoration(
        color: AppTheme.glassOverlay(context).withOpacity(0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: transaction.category.color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              transaction.category.icon,
              color: transaction.category.color,
              size: 20,
            ),
          ),
          const SizedBox(width: GlassTokens.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: AppTheme.titleMedium.copyWith(
                    color: AppTheme.textPrimary(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${transaction.category.label}  •  ${DateFormat('MMM dd, yyyy').format(transaction.date)}',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textTertiary(context),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}${CurrencyService.format(transaction.amount, currency)}',
            style: AppTheme.titleMedium.copyWith(
              color: isIncome
                  ? AppTheme.success(context)
                  : AppTheme.error(context),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypePickerTile extends StatelessWidget {
  const _TypePickerTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(GlassTokens.spacingLG),
      borderRadius: 28,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: GlassTokens.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.titleMedium.copyWith(
                    color: AppTheme.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textTertiary(context),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded,
              size: 16, color: AppTheme.textTertiary(context)),
        ],
      ),
    );
  }
}


