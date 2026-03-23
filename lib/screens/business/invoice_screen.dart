import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:fintracker_app/models/invoice.dart';
import 'package:fintracker_app/providers/auth_provider.dart';
import 'package:fintracker_app/providers/invoice_provider.dart';
import 'package:fintracker_app/providers/theme_provider.dart';
import 'package:fintracker_app/screens/business/invoice_detail.dart';
import 'package:fintracker_app/services/currency_service.dart';
import 'package:fintracker_app/services/export_service.dart';
import 'package:fintracker_app/theme/app_theme.dart';
import 'package:fintracker_app/theme/glass_tokens.dart';
import 'package:fintracker_app/widgets/glass_app_bar.dart';
import 'package:fintracker_app/widgets/glass_button.dart';
import 'package:fintracker_app/widgets/glass_card.dart';
import 'package:fintracker_app/widgets/glass_text_field.dart';

class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InvoiceProvider>();
    final auth = context.watch<AuthProvider>();
    final currency = context.watch<ThemeProvider>().currencyCode;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: GlassAppBar(
            title: 'Invoices',
            actions: [
              if (auth.canEdit)
                GlassButton(
                  label: 'Create Invoice',
                  icon: Icons.add_rounded,
                  small: true,
                  gradientColors: AppTheme.accentGradient,
                  onPressed: () => _showCreateInvoice(context),
                ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: GlassTokens.spacingMD),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryPill(
                    label: 'Paid',
                    value: '${provider.paidInvoices.length}',
                    color: AppTheme.success(context),
                    icon: Icons.check_circle_rounded,
                  ),
                ),
                const SizedBox(width: GlassTokens.spacingSM),
                Expanded(
                  child: _SummaryPill(
                    label: 'Pending',
                    value: '${provider.pendingInvoices.length}',
                    color: AppTheme.warning(context),
                    icon: Icons.schedule_rounded,
                  ),
                ),
                const SizedBox(width: GlassTokens.spacingSM),
                Expanded(
                  child: _SummaryPill(
                    label: 'Overdue',
                    value: '${provider.overdueInvoices.length}',
                    color: AppTheme.error(context),
                    icon: Icons.warning_amber_rounded,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(GlassTokens.spacingMD),
            child: GlassCard(
              padding: const EdgeInsets.all(GlassTokens.spacingLG),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final showTable = constraints.maxWidth >= 920;
                  if (provider.invoices.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: GlassTokens.spacingXXL,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 58,
                            color: AppTheme.textTertiary(context),
                          ),
                          const SizedBox(height: GlassTokens.spacingMD),
                          Text(
                            'No invoices generated yet.',
                            style: AppTheme.headlineMedium.copyWith(
                              color: AppTheme.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!showTable) {
                    return Column(
                      children: provider.invoices
                          .map(
                            (invoice) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: GlassTokens.spacingSM,
                              ),
                              child: _MobileInvoiceCard(
                                invoice: invoice,
                                currency: currency,
                                canEdit: auth.canEdit,
                              ),
                            ),
                          )
                          .toList(),
                    );
                  }

                  return Column(
                    children: [
                      Row(
                        children: [
                          _headerCell(context, 'CLIENT', flex: 3),
                          _headerCell(context, 'ISSUE DATE', flex: 2),
                          _headerCell(context, 'DUE DATE', flex: 2),
                          _headerCell(context, 'STATUS', flex: 2),
                          _headerCell(context, 'AMOUNT', flex: 2, end: true),
                          _headerCell(context, 'ACTIONS', flex: 2, end: true),
                        ],
                      ),
                      const SizedBox(height: GlassTokens.spacingMD),
                      Divider(color: AppTheme.glassBorder(context), height: 1),
                      ...provider.invoices.map(
                        (invoice) => _DesktopInvoiceRow(
                          invoice: invoice,
                          currency: currency,
                          canEdit: auth.canEdit,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: GlassTokens.spacingXXL)),
      ],
    );
  }

  Widget _headerCell(BuildContext context, String text,
      {required int flex, bool end = false}) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: end ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          text,
          style: AppTheme.labelLarge.copyWith(
            color: AppTheme.textSecondary(context),
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }

  static void _showCreateInvoice(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CreateInvoiceSheet(),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(GlassTokens.spacingMD),
      borderRadius: 24,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: GlassTokens.spacingMD),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: AppTheme.titleLarge.copyWith(color: color)),
              Text(
                label,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textTertiary(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DesktopInvoiceRow extends StatelessWidget {
  const _DesktopInvoiceRow({
    required this.invoice,
    required this.currency,
    required this.canEdit,
  });

  final Invoice invoice;
  final String currency;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(context, invoice);
    final provider = context.read<InvoiceProvider>();

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => InvoiceDetail(invoice: invoice)),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: GlassTokens.spacingMD,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppTheme.glassBorder(context)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.clientName,
                    style: AppTheme.titleMedium.copyWith(
                      color: AppTheme.textPrimary(context),
                    ),
                  ),
                  Text(
                    invoice.invoiceNumber,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textTertiary(context),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                DateFormat('MMM dd, yyyy').format(invoice.issueDate),
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary(context),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                DateFormat('MMM dd, yyyy').format(invoice.dueDate),
                style: AppTheme.bodyMedium.copyWith(
                  color: invoice.isOverdue
                      ? AppTheme.error(context)
                      : AppTheme.textSecondary(context),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    invoice.isOverdue ? 'OVERDUE' : invoice.status.name.toUpperCase(),
                    style: AppTheme.labelSmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  CurrencyService.format(invoice.total, currency),
                  style: AppTheme.titleLarge.copyWith(
                    color: AppTheme.textPrimary(context),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 6,
                  children: [
                    IconButton(
                      onPressed: () async {
                        final path = await ExportService.exportInvoicePDF(invoice);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('PDF saved to $path')),
                        );
                      },
                      icon: Icon(
                        Icons.picture_as_pdf_outlined,
                        color: AppTheme.textTertiary(context),
                      ),
                    ),
                    if (canEdit && invoice.status != InvoiceStatus.paid)
                      IconButton(
                        onPressed: () => provider.markAsPaid(invoice.id),
                        icon: Icon(
                          Icons.check_circle_outline_rounded,
                          color: AppTheme.success(context),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileInvoiceCard extends StatelessWidget {
  const _MobileInvoiceCard({
    required this.invoice,
    required this.currency,
    required this.canEdit,
  });

  final Invoice invoice;
  final String currency;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(context, invoice);
    final provider = context.read<InvoiceProvider>();

    return GlassCard(
      padding: const EdgeInsets.all(GlassTokens.spacingMD),
      borderRadius: 26,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => InvoiceDetail(invoice: invoice)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.clientName,
                      style: AppTheme.titleMedium.copyWith(
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                    Text(
                      invoice.invoiceNumber,
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
                  invoice.isOverdue ? 'OVERDUE' : invoice.status.name.toUpperCase(),
                  style: AppTheme.labelSmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: GlassTokens.spacingSM),
          Text(
            'Due ${DateFormat('MMM dd, yyyy').format(invoice.dueDate)}',
            style: AppTheme.bodySmall.copyWith(
              color: invoice.isOverdue
                  ? AppTheme.error(context)
                  : AppTheme.textTertiary(context),
            ),
          ),
          const SizedBox(height: GlassTokens.spacingSM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                CurrencyService.format(invoice.total, currency),
                style: AppTheme.titleLarge.copyWith(
                  color: AppTheme.textPrimary(context),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      final path = await ExportService.exportInvoicePDF(invoice);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('PDF saved to $path')),
                      );
                    },
                    icon: Icon(
                      Icons.picture_as_pdf_outlined,
                      color: AppTheme.textTertiary(context),
                    ),
                  ),
                  if (canEdit && invoice.status != InvoiceStatus.paid)
                    IconButton(
                      onPressed: () => provider.markAsPaid(invoice.id),
                      icon: Icon(
                        Icons.check_circle_outline_rounded,
                        color: AppTheme.success(context),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _statusColor(BuildContext context, Invoice invoice) {
  switch (invoice.status) {
    case InvoiceStatus.paid:
      return AppTheme.success(context);
    case InvoiceStatus.sent:
    case InvoiceStatus.partial:
      return invoice.isOverdue
          ? AppTheme.error(context)
          : AppTheme.warning(context);
    case InvoiceStatus.overdue:
      return AppTheme.error(context);
    case InvoiceStatus.cancelled:
      return AppTheme.textTertiary(context);
    case InvoiceStatus.draft:
      return AppTheme.textSecondary(context);
  }
}

class _CreateInvoiceSheet extends StatefulWidget {
  const _CreateInvoiceSheet();

  @override
  State<_CreateInvoiceSheet> createState() => _CreateInvoiceSheetState();
}

class _CreateInvoiceSheetState extends State<_CreateInvoiceSheet> {
  final TextEditingController _clientController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController(text: '1');
  final List<InvoiceItem> _items = [];
  double _taxRate = 0.10;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));

  @override
  void dispose() {
    _clientController.dispose();
    _emailController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
        color: AppTheme.bg(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(GlassTokens.spacingLG),
              child: Row(
                children: [
                  Text(
                    'Create Invoice',
                    style: AppTheme.headlineMedium.copyWith(
                      color: AppTheme.textPrimary(context),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppTheme.textTertiary(context),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: GlassTokens.spacingMD),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlassTextField(
                      controller: _clientController,
                      hint: 'Client name',
                      prefixIcon: Icons.person_rounded,
                    ),
                    const SizedBox(height: GlassTokens.spacingMD),
                    GlassTextField(
                      controller: _emailController,
                      hint: 'Client email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: GlassTokens.spacingLG),
                    Text(
                      'Line Items',
                      style: AppTheme.labelLarge.copyWith(
                        color: AppTheme.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: GlassTokens.spacingSM),
                    ..._items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: GlassTokens.spacingSM),
                        child: GlassCard(
                          padding: const EdgeInsets.all(GlassTokens.spacingMD),
                          borderRadius: 24,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.description,
                                  style: AppTheme.bodyLarge.copyWith(
                                    color: AppTheme.textPrimary(context),
                                  ),
                                ),
                              ),
                              Text(
                                '${item.quantity}x',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.textTertiary(context),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                CurrencyService.format(item.total, 'USD'),
                                style: AppTheme.titleMedium.copyWith(
                                  color: AppTheme.textPrimary(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: GlassTextField(
                            controller: _descController,
                            hint: 'Description',
                            prefixIcon: Icons.description_outlined,
                          ),
                        ),
                        const SizedBox(width: GlassTokens.spacingSM),
                        Expanded(
                          child: GlassTextField(
                            controller: _qtyController,
                            hint: 'Qty',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: GlassTokens.spacingSM),
                        Expanded(
                          child: GlassTextField(
                            controller: _priceController,
                            hint: 'Price',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: GlassTokens.spacingSM),
                    GlassButton(
                      label: 'Add Item',
                      icon: Icons.add_rounded,
                      small: true,
                      onPressed: _addItem,
                    ),
                    const SizedBox(height: GlassTokens.spacingLG),
                    GlassCard(
                      padding: const EdgeInsets.all(GlassTokens.spacingMD),
                      borderRadius: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Invoice Options',
                            style: AppTheme.titleMedium.copyWith(
                              color: AppTheme.textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: GlassTokens.spacingMD),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Tax Rate',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.textSecondary(context),
                                  ),
                                ),
                              ),
                              DropdownButton<double>(
                                value: _taxRate,
                                underline: const SizedBox.shrink(),
                                items: const [0.0, 0.05, 0.10, 0.15]
                                    .map(
                                      (value) => DropdownMenuItem<double>(
                                        value: value,
                                        child: Text('${(value * 100).round()}%'),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() => _taxRate = value);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: GlassTokens.spacingMD),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Due Date',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.textSecondary(context),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: _pickDueDate,
                                child: Text(DateFormat('MMM dd, yyyy').format(_dueDate)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: GlassTokens.spacingLG),
                    GlassTextField(
                      controller: _notesController,
                      hint: 'Notes (optional)',
                      prefixIcon: Icons.notes_outlined,
                      maxLines: 2,
                    ),
                    const SizedBox(height: GlassTokens.spacingXL),
                    GlassButton(
                      label: 'Create Invoice',
                      icon: Icons.check_rounded,
                      isExpanded: true,
                      gradientColors: AppTheme.accentGradient,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: GlassTokens.spacingXXL),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addItem() {
    if (_descController.text.trim().isEmpty || _priceController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _items.add(
        InvoiceItem(
          description: _descController.text.trim(),
          quantity: int.tryParse(_qtyController.text.trim()) ?? 1,
          unitPrice: double.tryParse(_priceController.text.trim()) ?? 0,
        ),
      );
      _descController.clear();
      _priceController.clear();
      _qtyController.text = '1';
    });
  }

  Future<void> _pickDueDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );

    if (selected != null) {
      setState(() => _dueDate = selected);
    }
  }

  void _submit() {
    if (_clientController.text.trim().isEmpty || _items.isEmpty) {
      return;
    }

    final provider = context.read<InvoiceProvider>();
    provider.addInvoice(
      Invoice(
        id: const Uuid().v4(),
        invoiceNumber: provider.generateInvoiceNumber(),
        clientName: _clientController.text.trim(),
        clientEmail: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        items: List<InvoiceItem>.from(_items),
        taxRate: _taxRate,
        status: InvoiceStatus.sent,
        issueDate: DateTime.now(),
        dueDate: _dueDate,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      ),
    );
    Navigator.of(context).pop();
  }
}

