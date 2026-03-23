import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:fintracker_app/models/budget.dart';
import 'package:fintracker_app/models/category.dart';
import 'package:fintracker_app/providers/auth_provider.dart';
import 'package:fintracker_app/providers/budget_provider.dart';
import 'package:fintracker_app/providers/theme_provider.dart';
import 'package:fintracker_app/services/currency_service.dart';
import 'package:fintracker_app/theme/app_theme.dart';
import 'package:fintracker_app/theme/glass_tokens.dart';
import 'package:fintracker_app/widgets/glass_app_bar.dart';
import 'package:fintracker_app/widgets/glass_button.dart';
import 'package:fintracker_app/widgets/glass_card.dart';
import 'package:fintracker_app/widgets/glass_progress_bar.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budgetProvider = context.watch<BudgetProvider>();
    final auth = context.watch<AuthProvider>();
    final currency = context.watch<ThemeProvider>().currencyCode;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: GlassAppBar(
            title: 'Budgets',
            actions: [
              if (auth.canEdit)
                GlassButton(
                  label: 'Create Budget',
                  icon: Icons.add_rounded,
                  small: true,
                  gradientColors: AppTheme.accentGradient,
                  onPressed: () => _showCreateBudget(context),
                ),
            ],
          ),
        ),
        if (budgetProvider.budgets.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(GlassTokens.spacingMD),
              child: GlassCard(
                padding: const EdgeInsets.all(GlassTokens.spacingXXL),
                child: Column(
                  children: [
                    const SizedBox(height: GlassTokens.spacingXL),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.accent(context).withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.track_changes_rounded,
                        size: 48,
                        color: AppTheme.accent(context),
                      ),
                    ),
                    const SizedBox(height: GlassTokens.spacingLG),
                    Text(
                      'No Budgets Set',
                      style: AppTheme.headlineLarge.copyWith(
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: GlassTokens.spacingSM),
                    Text(
                      'Create budgets for your categories to keep spending calm, visible, and intentional.',
                      textAlign: TextAlign.center,
                      style: AppTheme.bodyLarge.copyWith(
                        color: AppTheme.textSecondary(context),
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: GlassTokens.spacingXL),
                    if (auth.canEdit)
                      GlassButton(
                        label: 'Create Your First Budget',
                        icon: Icons.add_rounded,
                        gradientColors: AppTheme.accentGradient,
                        onPressed: () => _showCreateBudget(context),
                      ),
                  ],
                ),
              ),
            ),
          )
        else ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: GlassTokens.spacingMD),
              child: GlassCard(
                padding: const EdgeInsets.all(GlassTokens.spacingXL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Overview',
                      style: AppTheme.headlineMedium.copyWith(
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: GlassTokens.spacingSM),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: CurrencyService.format(
                              budgetProvider.totalBudgetSpent,
                              currency,
                            ),
                            style: AppTheme.amountMedium.copyWith(
                              color: AppTheme.textPrimary(context),
                            ),
                          ),
                          TextSpan(
                            text: ' / ${CurrencyService.format(budgetProvider.totalBudgetLimit, currency)}',
                            style: AppTheme.titleLarge.copyWith(
                              color: AppTheme.textTertiary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: GlassTokens.spacingLG),
                    GlassProgressBar(
                      progress: budgetProvider.overallProgress,
                      label: 'Overall Usage',
                      sublabel: '${(budgetProvider.overallProgress * 100).toStringAsFixed(0)}% used',
                      height: 14,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(GlassTokens.spacingMD),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.crossAxisExtent >= 1080 ? 2 : 1;
                return SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final budget = budgetProvider.budgets[index];
                      return _BudgetCard(budget: budget, currency: currency);
                    },
                    childCount: budgetProvider.budgets.length,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: GlassTokens.spacingMD,
                    mainAxisSpacing: GlassTokens.spacingMD,
                    childAspectRatio: columns == 2 ? 1.45 : 1.9,
                  ),
                );
              },
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: GlassTokens.spacingXXL)),
      ],
    );
  }

  static void _showCreateBudget(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CreateBudgetSheet(),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({required this.budget, required this.currency});

  final Budget budget;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final statusColor = budget.isOverBudget
        ? AppTheme.error(context)
        : budget.isNearLimit
            ? AppTheme.warning(context)
            : budget.category.color;

    return GlassCard(
      padding: const EdgeInsets.all(GlassTokens.spacingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: budget.category.color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  budget.category.icon,
                  color: budget.category.color,
                ),
              ),
              const SizedBox(width: GlassTokens.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      budget.category.label,
                      style: AppTheme.titleLarge.copyWith(
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                    Text(
                      '${CurrencyService.format(budget.remaining, currency)} remaining',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textTertiary(context),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  budget.isOverBudget
                      ? 'Over'
                      : budget.isNearLimit
                          ? 'Near limit'
                          : 'Healthy',
                  style: AppTheme.labelSmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          GlassProgressBar(
            progress: budget.progress,
            label: '${CurrencyService.format(budget.spent, currency)} spent',
            sublabel: CurrencyService.format(budget.limit, currency),
            gradientColors: [statusColor, statusColor.withOpacity(0.55)],
            height: 10,
          ),
        ],
      ),
    );
  }
}

class _CreateBudgetSheet extends StatefulWidget {
  const _CreateBudgetSheet();

  @override
  State<_CreateBudgetSheet> createState() => _CreateBudgetSheetState();
}

class _CreateBudgetSheetState extends State<_CreateBudgetSheet> {
  final TextEditingController _amountController = TextEditingController();
  TransactionCategory _selectedCategory = TransactionCategory.groceries;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = TransactionCategory.values
        .where((category) => !category.isBusinessCategory)
        .toList();

    return Container(
      padding: const EdgeInsets.all(GlassTokens.spacingLG),
      decoration: BoxDecoration(
        color: AppTheme.bg(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Budget',
              style: AppTheme.headlineMedium.copyWith(
                color: AppTheme.textPrimary(context),
              ),
            ),
            const SizedBox(height: GlassTokens.spacingLG),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: categories.map((category) {
                final active = category == _selectedCategory;
                return ChoiceChip(
                  label: Text(category.label),
                  avatar: Icon(category.icon, size: 18, color: category.color),
                  selected: active,
                  onSelected: (_) => setState(() => _selectedCategory = category),
                );
              }).toList(),
            ),
            const SizedBox(height: GlassTokens.spacingLG),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'Budget amount',
                filled: true,
                fillColor: AppTheme.glassOverlay(context).withOpacity(0.45),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: GlassTokens.spacingLG),
            GlassButton(
              label: 'Save Budget',
              icon: Icons.check_rounded,
              isExpanded: true,
              gradientColors: AppTheme.accentGradient,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      return;
    }

    final now = DateTime.now();
    context.read<BudgetProvider>().addBudget(
          Budget(
            id: const Uuid().v4(),
            category: _selectedCategory,
            limit: amount,
            startDate: DateTime(now.year, now.month, 1),
            endDate: DateTime(now.year, now.month + 1, 0),
          ),
        );

    Navigator.of(context).pop();
  }
}

