import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fintracker_app/theme/app_theme.dart';
import 'package:fintracker_app/theme/glass_tokens.dart';
import 'package:fintracker_app/models/invoice.dart';
import 'package:fintracker_app/providers/invoice_provider.dart';
import 'package:fintracker_app/providers/theme_provider.dart';
import 'package:fintracker_app/services/currency_service.dart';
import 'package:fintracker_app/services/export_service.dart';
import 'package:fintracker_app/widgets/glass_card.dart';
import 'package:fintracker_app/widgets/glass_button.dart';
import 'package:fintracker_app/widgets/glass_app_bar.dart';
import 'package:intl/intl.dart';

class InvoiceDetail extends StatelessWidget {
  final Invoice invoice;

  const InvoiceDetail({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<ThemeProvider>().currencyCode;
    final invProvider = context.watch<InvoiceProvider>();

    Color statusColor;
    switch (invoice.status) {
      case InvoiceStatus.paid:
        statusColor = AppTheme.success(context);
        break;
      case InvoiceStatus.sent:
        statusColor = invoice.isOverdue ? AppTheme.error(context) : AppTheme.warning(context);
        break;
      default:
        statusColor = AppTheme.textTertiary(context);
    }

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
              title: invoice.invoiceNumber,
              actions: [
                GlassIconButton(
                  icon: Icons.picture_as_pdf_rounded,
                  onTap: () async {
                    final path = await ExportService.exportInvoicePDF(invoice);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('PDF saved to $path')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          // Status header
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: GlassTokens.spacingMD),
              child: GlassCard(
                padding: EdgeInsets.all(GlassTokens.spacingXL),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(GlassTokens.radiusFull),
                      ),
                      child: Text(
                        invoice.isOverdue ? 'OVERDUE' : invoice.status.name.toUpperCase(),
                        style: AppTheme.labelLarge.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(height: GlassTokens.spacingLG),
                    Text(
                      CurrencyService.format(invoice.total, currency),
                      style: AppTheme.amountLarge.copyWith(color: AppTheme.textPrimary(context)),
                    ),
                    SizedBox(height: GlassTokens.spacingSM),
                    if (invoice.amountPaid > 0 && invoice.status != InvoiceStatus.paid)
                      Text(
                        'Amount Due: ${CurrencyService.format(invoice.amountDue, currency)}',
                        style: AppTheme.bodyMedium.copyWith(color: AppTheme.warning(context)),
                      ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: GlassTokens.spacingMD)),
          // Client info
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: GlassTokens.spacingMD),
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Client', style: AppTheme.labelLarge.copyWith(color: AppTheme.textTertiary(context))),
                    SizedBox(height: GlassTokens.spacingSM),
                    Text(invoice.clientName, style: AppTheme.titleLarge.copyWith(color: AppTheme.textPrimary(context))),
                    if (invoice.clientEmail != null)
                      Text(invoice.clientEmail!, style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary(context))),
                    SizedBox(height: GlassTokens.spacingMD),
                    Divider(color: AppTheme.glassBorder(context)),
                    SizedBox(height: GlassTokens.spacingSM),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Issue Date', style: AppTheme.labelSmall.copyWith(color: AppTheme.textTertiary(context))),
                            Text(DateFormat('MMM dd, yyyy').format(invoice.issueDate),
                                style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary(context))),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Due Date', style: AppTheme.labelSmall.copyWith(color: AppTheme.textTertiary(context))),
                            Text(DateFormat('MMM dd, yyyy').format(invoice.dueDate),
                                style: AppTheme.bodyMedium.copyWith(
                                    color: invoice.isOverdue ? AppTheme.error(context) : AppTheme.textPrimary(context))),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: GlassTokens.spacingMD)),
          // Line items
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: GlassTokens.spacingMD),
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Items', style: AppTheme.labelLarge.copyWith(color: AppTheme.textTertiary(context))),
                    SizedBox(height: GlassTokens.spacingMD),
                    ...invoice.items.map((item) => Padding(
                      padding: EdgeInsets.only(bottom: GlassTokens.spacingSM),
                      child: Row(
                        children: [
                          Expanded(child: Text(item.description, style: AppTheme.bodyLarge.copyWith(color: AppTheme.textPrimary(context)))),
                          Text('${item.quantity}x', style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary(context))),
                          SizedBox(width: 12),
                          Text(CurrencyService.format(item.total, currency),
                              style: AppTheme.titleMedium.copyWith(color: AppTheme.textPrimary(context))),
                        ],
                      ),
                    )),
                    Divider(color: AppTheme.glassBorder(context)),
                    _buildLine('Subtotal', CurrencyService.format(invoice.subtotal, currency), context),
                    if (invoice.taxRate > 0)
                      _buildLine('Tax (${(invoice.taxRate * 100).toStringAsFixed(0)}%)',
                          CurrencyService.format(invoice.taxAmount, currency), context),
                    SizedBox(height: GlassTokens.spacingSM),
                    _buildLine('Total', CurrencyService.format(invoice.total, currency), context, bold: true),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: GlassTokens.spacingLG)),
          // Actions
          if (invoice.status != InvoiceStatus.paid)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: GlassTokens.spacingMD),
                child: GlassButton(
                  label: 'Mark as Paid',
                  icon: Icons.check_circle_rounded,
                  isExpanded: true,
                  gradientColors: AppTheme.incomeGradient,
                  onPressed: () {
                    invProvider.markAsPaid(invoice.id);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          SliverToBoxAdapter(child: SizedBox(height: GlassTokens.spacingXXL)),
        ],
      ),
    );
  }

  Widget _buildLine(String label, String value, BuildContext context, {bool bold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: (bold ? AppTheme.titleMedium : AppTheme.bodyMedium).copyWith(
              color: AppTheme.textSecondary(context),
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
          Text(value, style: (bold ? AppTheme.titleMedium : AppTheme.bodyMedium).copyWith(
              color: AppTheme.textPrimary(context),
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
        ],
      ),
    );
  }
}

