import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fintracker_app/theme/app_theme.dart';
import 'package:fintracker_app/theme/glass_tokens.dart';
import 'package:fintracker_app/providers/transaction_provider.dart';
import 'package:fintracker_app/providers/theme_provider.dart';
import 'package:fintracker_app/services/currency_service.dart';
import 'package:fintracker_app/widgets/glass_card.dart';
import 'package:fintracker_app/widgets/glass_app_bar.dart';

class TaxScreen extends StatelessWidget {
  const TaxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final txnProvider = context.watch<TransactionProvider>();
    final currency = context.watch<ThemeProvider>().currencyCode;

    // Group transactions by tax category
    final taxGroups = <String, double>{};
    for (final t in txnProvider.businessTransactions) {
      final taxCat = t.category.taxCategory;
      taxGroups[taxCat] = (taxGroups[taxCat] ?? 0) + t.amount;
    }

    final totalDeductions = taxGroups.entries
        .where((e) => e.key.contains('Deduction') || e.key.contains('Capital Expenditure'))
        .fold(0.0, (sum, e) => sum + e.value);

    final totalTaxableIncome = taxGroups.entries
        .where((e) => e.key.contains('Income') || e.key.contains('Capital Gains'))
        .fold(0.0, (sum, e) => sum + e.value);

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: GlassAppBar(
              leading: GlassIconButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.pop(context),
              ),
              title: 'Tax Overview',
            ),
          ),
          // Summary
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: GlassTokens.spacingMD),
              child: GlassCard(
                padding: EdgeInsets.all(GlassTokens.spacingXL),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text('Taxable Income', style: AppTheme.labelSmall.copyWith(color: AppTheme.textTertiary(context))),
                            SizedBox(height: 4),
                            Text(CurrencyService.formatCompact(totalTaxableIncome, currency),
                                style: AppTheme.amountMedium.copyWith(color: AppTheme.success(context))),
                          ],
                        ),
                        Container(width: 1, height: 40, color: AppTheme.glassBorder(context)),
                        Column(
                          children: [
                            Text('Deductions', style: AppTheme.labelSmall.copyWith(color: AppTheme.textTertiary(context))),
                            SizedBox(height: 4),
                            Text(CurrencyService.formatCompact(totalDeductions, currency),
                                style: AppTheme.amountMedium.copyWith(color: AppTheme.warning(context))),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: GlassTokens.spacingLG),
                    Container(
                      padding: EdgeInsets.all(GlassTokens.spacingMD),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(GlassTokens.radiusMedium),
                        color: AppTheme.accent(context).withOpacity(0.1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline_rounded, color: AppTheme.accent(context), size: 18),
                          SizedBox(width: 8),
                          Text('Auto-classified from your transactions',
                              style: AppTheme.bodySmall.copyWith(color: AppTheme.accent(context))),
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
              padding: EdgeInsets.all(GlassTokens.spacingMD),
              child: Text('Tax Categories', style: AppTheme.headlineMedium.copyWith(color: AppTheme.textPrimary(context))),
            ),
          ),
          // Tax category breakdown
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final entry = taxGroups.entries.toList()[index];
                final isIncome = entry.key.contains('Income') || entry.key.contains('Capital Gains');
                final color = isIncome ? AppTheme.success(context) : AppTheme.warning(context);
                final icon = isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: GlassTokens.spacingMD,
                    vertical: GlassTokens.spacingXS,
                  ),
                  child: GlassCard(
                    padding: EdgeInsets.all(GlassTokens.spacingMD),
                    borderRadius: GlassTokens.radiusMedium,
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(icon, color: color, size: 20),
                        ),
                        SizedBox(width: GlassTokens.spacingMD),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(entry.key, style: AppTheme.titleMedium.copyWith(color: AppTheme.textPrimary(context))),
                              Text(isIncome ? 'Taxable' : 'Deductible',
                                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary(context))),
                            ],
                          ),
                        ),
                        Text(CurrencyService.format(entry.value, currency),
                            style: AppTheme.amountSmall.copyWith(color: color)),
                      ],
                    ),
                  ),
                );
              },
              childCount: taxGroups.length,
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: GlassTokens.spacingXXL)),
        ],
      ),
    );
  }
}


