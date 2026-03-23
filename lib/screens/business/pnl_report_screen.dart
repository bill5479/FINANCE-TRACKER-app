import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fintracker_app/theme/app_theme.dart';
import 'package:fintracker_app/theme/glass_tokens.dart';
import 'package:fintracker_app/providers/transaction_provider.dart';
import 'package:fintracker_app/providers/theme_provider.dart';
import 'package:fintracker_app/services/currency_service.dart';
import 'package:fintracker_app/services/export_service.dart';
import 'package:fintracker_app/widgets/glass_card.dart';
import 'package:fintracker_app/widgets/glass_button.dart';
import 'package:fintracker_app/widgets/glass_app_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class PnLReportScreen extends StatefulWidget {
  const PnLReportScreen({super.key});

  @override
  State<PnLReportScreen> createState() => _PnLReportScreenState();
}

class _PnLReportScreenState extends State<PnLReportScreen> {
  bool _showBusiness = true;

  @override
  Widget build(BuildContext context) {
    final txnProvider = context.watch<TransactionProvider>();
    final currency = context.watch<ThemeProvider>().currencyCode;
    final monthlyPnL = txnProvider.getMonthlyPnL(business: _showBusiness);

    final totalIncome = _showBusiness ? txnProvider.businessIncome : txnProvider.personalIncome;
    final totalExpense = _showBusiness ? txnProvider.businessExpense : txnProvider.personalExpense;
    final netPnL = totalIncome - totalExpense;

    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: GlassAppBar(
            title: 'Reports',
            actions: [
              GlassIconButton(
                icon: Icons.file_download_outlined,
                onTap: () async {
                  final transactions = _showBusiness
                      ? txnProvider.businessTransactions
                      : txnProvider.personalTransactions;
                  final path = await ExportService.exportPnLReport(
                    transactions: transactions,
                    currencyCode: currency,
                    startDate: DateTime(DateTime.now().year, 1, 1),
                    endDate: DateTime.now(),
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('PDF exported to $path')),
                    );
                  }
                },
              ),
            ],
          ),
        ),

        // Toggle
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: GlassTokens.spacingMD),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _showBusiness = false),
                    child: AnimatedContainer(
                      duration: GlassTokens.animMedium,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(GlassTokens.radiusFull),
                        color: !_showBusiness
                            ? AppTheme.accent(context).withOpacity(0.2)
                            : AppTheme.glassOverlay(context),
                      ),
                      child: Center(
                        child: Text('Personal', style: AppTheme.labelLarge.copyWith(
                          color: !_showBusiness ? AppTheme.accent(context) : AppTheme.textSecondary(context),
                        )),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: GlassTokens.spacingSM),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _showBusiness = true),
                    child: AnimatedContainer(
                      duration: GlassTokens.animMedium,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(GlassTokens.radiusFull),
                        color: _showBusiness
                            ? AppTheme.accent(context).withOpacity(0.2)
                            : AppTheme.glassOverlay(context),
                      ),
                      child: Center(
                        child: Text('Business', style: AppTheme.labelLarge.copyWith(
                          color: _showBusiness ? AppTheme.accent(context) : AppTheme.textSecondary(context),
                        )),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: GlassTokens.spacingMD)),

        // Summary Cards
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: GlassTokens.spacingMD),
            child: Row(
              children: [
                Expanded(child: _buildKPICard(context, 'Income', CurrencyService.formatCompact(totalIncome, currency), AppTheme.success(context), Icons.trending_up_rounded)),
                SizedBox(width: GlassTokens.spacingSM),
                Expanded(child: _buildKPICard(context, 'Expenses', CurrencyService.formatCompact(totalExpense, currency), AppTheme.error(context), Icons.trending_down_rounded)),
                SizedBox(width: GlassTokens.spacingSM),
                Expanded(child: _buildKPICard(context, 'Net P&L', CurrencyService.formatCompact(netPnL, currency), netPnL >= 0 ? AppTheme.success(context) : AppTheme.error(context), Icons.account_balance_rounded)),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: GlassTokens.spacingMD)),

        // Chart
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: GlassTokens.spacingMD),
            child: GlassCard(
              padding: EdgeInsets.all(GlassTokens.spacingLG),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Monthly Overview', style: AppTheme.headlineMedium.copyWith(color: AppTheme.textPrimary(context))),
                  SizedBox(height: GlassTokens.spacingLG),
                  SizedBox(
                    height: 220,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: monthlyPnL.isEmpty ? 100 :
                            monthlyPnL.map((m) => m.income > m.expense ? m.income : m.expense).reduce((a, b) => a > b ? a : b) * 1.3,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final label = rodIndex == 0 ? 'Income' : 'Expenses';
                              return BarTooltipItem(
                                '$label\n${CurrencyService.formatCompact(rod.toY, currency)}',
                                AppTheme.bodySmall.copyWith(color: Colors.white),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            getTitlesWidget: (value, meta) => Text(
                              CurrencyService.formatCompact(value, currency),
                              style: AppTheme.labelSmall.copyWith(color: AppTheme.textTertiary(context), fontSize: 9),
                            ),
                          )),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= monthlyPnL.length) return SizedBox();
                              return Text(DateFormat('MMM').format(monthlyPnL[value.toInt()].month),
                                  style: AppTheme.labelSmall.copyWith(color: AppTheme.textTertiary(context), fontSize: 10));
                            },
                          )),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: monthlyPnL.isEmpty ? 25 :
                              monthlyPnL.map((m) => m.income > m.expense ? m.income : m.expense).reduce((a, b) => a > b ? a : b) / 4,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: AppTheme.glassBorder(context),
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(monthlyPnL.length, (i) {
                          final m = monthlyPnL[i];
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: m.income,
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: AppTheme.incomeGradient,
                                ),
                                width: 14,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              BarChartRodData(
                                toY: m.expense,
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: AppTheme.expenseGradient,
                                ),
                                width: 14,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                  SizedBox(height: GlassTokens.spacingMD),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _legendDot(AppTheme.success(context), 'Income'),
                      SizedBox(width: GlassTokens.spacingLG),
                      _legendDot(AppTheme.error(context), 'Expenses'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: GlassTokens.spacingMD)),

        // Export buttons
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: GlassTokens.spacingMD),
            child: Row(
              children: [
                Expanded(
                  child: GlassButton(
                    label: 'Export CSV',
                    icon: Icons.table_chart_rounded,
                    isExpanded: true,
                    onPressed: () async {
                      final transactions = _showBusiness
                          ? txnProvider.businessTransactions
                          : txnProvider.personalTransactions;
                      final path = await ExportService.exportTransactionsCSV(transactions);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('CSV exported to $path')),
                        );
                      }
                    },
                  ),
                ),
                SizedBox(width: GlassTokens.spacingSM),
                Expanded(
                  child: GlassButton(
                    label: 'Export PDF',
                    icon: Icons.picture_as_pdf_rounded,
                    isExpanded: true,
                    gradientColors: AppTheme.accentGradient,
                    onPressed: () async {
                      final transactions = _showBusiness
                          ? txnProvider.businessTransactions
                          : txnProvider.personalTransactions;
                      final path = await ExportService.exportPnLReport(
                        transactions: transactions,
                        currencyCode: currency,
                        startDate: DateTime(DateTime.now().year, 1, 1),
                        endDate: DateTime.now(),
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('PDF exported to $path')),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // Expense by category
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(GlassTokens.spacingMD),
            child: GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Expenses by Category', style: AppTheme.headlineMedium.copyWith(color: AppTheme.textPrimary(context))),
                  SizedBox(height: GlassTokens.spacingMD),
                  ...txnProvider.getExpenseByCategory(business: _showBusiness).entries.map((e) {
                    final pct = totalExpense > 0 ? e.value / totalExpense : 0.0;
                    return Padding(
                      padding: EdgeInsets.only(bottom: GlassTokens.spacingSM),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: e.key.color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(e.key.icon, color: e.key.color, size: 16),
                          ),
                          SizedBox(width: GlassTokens.spacingSM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(e.key.label, style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary(context))),
                                    Text(CurrencyService.format(e.value, currency),
                                        style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary(context), fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: pct,
                                    backgroundColor: AppTheme.glassOverlay(context),
                                    valueColor: AlwaysStoppedAnimation(e.key.color),
                                    minHeight: 6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: GlassTokens.spacingXXL)),
      ],
    );
  }

  Widget _buildKPICard(BuildContext context, String label, String value, Color color, IconData icon) {
    return GlassCard(
      padding: EdgeInsets.all(GlassTokens.spacingMD),
      borderRadius: GlassTokens.radiusMedium,
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          SizedBox(height: 6),
          Text(value, style: AppTheme.titleMedium.copyWith(color: color, fontWeight: FontWeight.w700)),
          Text(label, style: AppTheme.labelSmall.copyWith(color: AppTheme.textTertiary(context))),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        SizedBox(width: 6),
        Text(label, style: AppTheme.bodySmall.copyWith(color: color)),
      ],
    );
  }
}

