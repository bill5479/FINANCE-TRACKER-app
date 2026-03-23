import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fintracker_app/theme/app_theme.dart';
import 'package:fintracker_app/theme/glass_tokens.dart';
import 'package:fintracker_app/providers/transaction_provider.dart';
import 'package:fintracker_app/providers/invoice_provider.dart';
import 'package:fintracker_app/providers/theme_provider.dart';
import 'package:fintracker_app/services/currency_service.dart';
import 'package:fintracker_app/models/transaction.dart';
import 'package:fintracker_app/models/invoice.dart';
import 'package:fintracker_app/widgets/glass_card.dart';
import 'package:fintracker_app/widgets/glass_button.dart';
import 'package:fintracker_app/widgets/glass_app_bar.dart';
import 'package:fintracker_app/screens/personal/add_transaction_sheet.dart';
import 'package:fintracker_app/screens/business/invoice_screen.dart';
import 'package:fintracker_app/screens/business/tax_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class BusinessDashboard extends StatelessWidget {
  const BusinessDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final txnProvider = context.watch<TransactionProvider>();
    final invProvider = context.watch<InvoiceProvider>();
    final currency = context.watch<ThemeProvider>().currencyCode;
    final monthlyPnL = txnProvider.getMonthlyPnL(business: true);

    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: [
        // App Bar
        SliverToBoxAdapter(
          child: GlassAppBar(
            title: 'Business',
            actions: [
              GlassIconButton(
                icon: Icons.receipt_long_rounded,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TaxScreen()),
                ),
              ),
              GlassIconButton(
                icon: Icons.notifications_outlined,
                onTap: () {},
                badge: invProvider.overdueInvoices.isNotEmpty
                    ? '${invProvider.overdueInvoices.length}'
                    : null,
              ),
            ],
          ),
        ),

        // P&L Summary Card
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: GlassTokens.spacingMD),
            child: GlassCard(
              padding: EdgeInsets.all(GlassTokens.spacingXL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profit & Loss',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary(context),
                    ),
                  ),
                  SizedBox(height: GlassTokens.spacingSM),
                  Text(
                    CurrencyService.format(txnProvider.businessProfit, currency),
                    style: AppTheme.amountLarge.copyWith(
                      color: txnProvider.businessProfit >= 0
                          ? AppTheme.success(context)
                          : AppTheme.error(context),
                    ),
                  ),
                  SizedBox(height: GlassTokens.spacingLG),
                  Row(
                    children: [
                      _buildStat(context, 'Revenue',
                          CurrencyService.formatCompact(txnProvider.businessIncome, currency),
                          AppTheme.success(context)),
                      SizedBox(width: GlassTokens.spacingMD),
                      _buildStat(context, 'Expenses',
                          CurrencyService.formatCompact(txnProvider.businessExpense, currency),
                          AppTheme.error(context)),
                    ],
                  ),
                  SizedBox(height: GlassTokens.spacingLG),
                  // Mini P&L Chart
                  SizedBox(
                    height: 160,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: monthlyPnL.isEmpty
                            ? 100
                            : monthlyPnL
                                    .map((m) =>
                                        m.income > m.expense ? m.income : m.expense)
                                    .reduce((a, b) => a > b ? a : b) *
                                1.2,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= monthlyPnL.length) return SizedBox();
                                return Text(
                                  DateFormat('MMM').format(monthlyPnL[value.toInt()].month),
                                  style: AppTheme.labelSmall.copyWith(
                                    color: AppTheme.textTertiary(context),
                                    fontSize: 10,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(monthlyPnL.length, (i) {
                          final m = monthlyPnL[i];
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: m.income,
                                color: AppTheme.success(context).withOpacity(0.7),
                                width: 12,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              BarChartRodData(
                                toY: m.expense,
                                color: AppTheme.error(context).withOpacity(0.7),
                                width: 12,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                  SizedBox(height: GlassTokens.spacingSM),
                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _legendDot(AppTheme.success(context), 'Income'),
                      SizedBox(width: GlassTokens.spacingMD),
                      _legendDot(AppTheme.error(context), 'Expenses'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Quick Actions
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(GlassTokens.spacingMD),
            child: Row(
              children: [
                Expanded(
                  child: GlassButton(
                    label: 'Add Revenue',
                    icon: Icons.add_rounded,
                    isExpanded: true,
                    gradientColors: AppTheme.incomeGradient,
                    onPressed: () => _showAddTransaction(context, TransactionType.income),
                  ),
                ),
                SizedBox(width: GlassTokens.spacingSM),
                Expanded(
                  child: GlassButton(
                    label: 'New Invoice',
                    icon: Icons.description_rounded,
                    isExpanded: true,
                    gradientColors: AppTheme.accentGradient,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => InvoiceScreen()),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Invoices Section
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: GlassTokens.spacingMD),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Outstanding Invoices',
                  style: AppTheme.headlineMedium.copyWith(
                    color: AppTheme.textPrimary(context),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => InvoiceScreen()),
                  ),
                  child: Text(
                    'View All',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.accent(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: GlassTokens.spacingSM)),

        // Invoice List
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final invoices = invProvider.invoices;
              if (index >= invoices.length) return null;
              final inv = invoices[index];
              return _buildInvoiceTile(context, inv, currency, invProvider);
            },
            childCount: invProvider.invoices.take(5).length,
          ),
        ),

        // Receivable summary
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(GlassTokens.spacingMD),
            child: GlassCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildReceivableStat(
                    context,
                    'Receivable',
                    CurrencyService.formatCompact(invProvider.totalReceivable, currency),
                    AppTheme.warning(context),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppTheme.glassBorder(context),
                  ),
                  _buildReceivableStat(
                    context,
                    'Collected',
                    CurrencyService.formatCompact(invProvider.totalCollected, currency),
                    AppTheme.success(context),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppTheme.glassBorder(context),
                  ),
                  _buildReceivableStat(
                    context,
                    'Overdue',
                    '${invProvider.overdueInvoices.length}',
                    AppTheme.error(context),
                  ),
                ],
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: GlassTokens.spacingXXL)),
      ],
    );
  }

  Widget _buildStat(BuildContext context, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: GlassTokens.spacingMD,
          vertical: GlassTokens.spacingSM,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(GlassTokens.radiusMedium),
          color: color.withOpacity(0.1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTheme.labelSmall.copyWith(color: AppTheme.textTertiary(context))),
            SizedBox(height: 4),
            Text(value, style: AppTheme.titleLarge.copyWith(color: color, fontWeight: FontWeight.w700)),
          ],
        ),
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

  Widget _buildReceivableStat(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: AppTheme.labelSmall.copyWith(color: AppTheme.textTertiary(context))),
        SizedBox(height: 4),
        Text(value, style: AppTheme.amountSmall.copyWith(color: color)),
      ],
    );
  }

  Widget _buildInvoiceTile(BuildContext context, Invoice inv, String currency, InvoiceProvider provider) {
    Color statusColor;
    switch (inv.status) {
      case InvoiceStatus.paid:
        statusColor = AppTheme.success(context);
        break;
      case InvoiceStatus.sent:
        statusColor = inv.isOverdue ? AppTheme.error(context) : AppTheme.warning(context);
        break;
      case InvoiceStatus.draft:
        statusColor = AppTheme.textTertiary(context);
        break;
      default:
        statusColor = AppTheme.textTertiary(context);
    }

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
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.receipt_rounded, color: statusColor, size: 22),
            ),
            SizedBox(width: GlassTokens.spacingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    inv.clientName,
                    style: AppTheme.titleMedium.copyWith(
                      color: AppTheme.textPrimary(context),
                    ),
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        inv.invoiceNumber,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textTertiary(context),
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          inv.isOverdue ? 'OVERDUE' : inv.status.name.toUpperCase(),
                          style: AppTheme.labelSmall.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyService.format(inv.total, currency),
                  style: AppTheme.amountSmall.copyWith(
                    color: AppTheme.textPrimary(context),
                  ),
                ),
                Text(
                  'Due ${DateFormat('MMM dd').format(inv.dueDate)}',
                  style: AppTheme.bodySmall.copyWith(
                    color: inv.isOverdue
                        ? AppTheme.error(context)
                        : AppTheme.textTertiary(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTransaction(BuildContext context, TransactionType type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTransactionSheet(type: type, isBusiness: true),
    );
  }
}

