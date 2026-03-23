import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:fintracker_app/theme/app_theme.dart';
import 'package:fintracker_app/theme/glass_tokens.dart';
import 'package:fintracker_app/models/transaction.dart';
import 'package:fintracker_app/models/category.dart';
import 'package:fintracker_app/providers/transaction_provider.dart';
import 'package:fintracker_app/providers/theme_provider.dart';
import 'package:fintracker_app/providers/budget_provider.dart';
import 'package:fintracker_app/services/currency_service.dart';
import 'package:fintracker_app/widgets/glass_card.dart';
import 'package:fintracker_app/widgets/glass_button.dart';
import 'package:fintracker_app/widgets/glass_text_field.dart';

class AddTransactionSheet extends StatefulWidget {
  final TransactionType type;
  final bool isBusiness;

  const AddTransactionSheet({
    super.key,
    required this.type,
    this.isBusiness = false,
  });

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  TransactionCategory _selectedCategory = TransactionCategory.other;
  bool _isRecurring = false;
  RecurrenceInterval _recurrence = RecurrenceInterval.monthly;
  DateTime _selectedDate = DateTime.now();
  String _selectedCurrency = 'USD';

  @override
  void initState() {
    super.initState();
    _selectedCurrency = context.read<ThemeProvider>().currencyCode;
    // Set default category based on type and business flag
    if (widget.isBusiness) {
      _selectedCategory = widget.type == TransactionType.income
          ? TransactionCategory.sales
          : TransactionCategory.marketing;
    } else {
      _selectedCategory = widget.type == TransactionType.income
          ? TransactionCategory.salary
          : TransactionCategory.groceries;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  List<TransactionCategory> get _categories {
    if (widget.isBusiness) {
      return TransactionCategory.values
          .where((c) => c.isBusinessCategory || c == TransactionCategory.other)
          .toList();
    }
    return TransactionCategory.values
        .where((c) => !c.isBusinessCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.type == TransactionType.income;
    final accentColor = isIncome ? AppTheme.success(context) : AppTheme.error(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppTheme.bg(context),
        borderRadius: BorderRadius.vertical(top: Radius.circular(GlassTokens.radiusLarge)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textTertiary(context).withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: EdgeInsets.all(GlassTokens.spacingLG),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                    color: accentColor,
                    size: 22,
                  ),
                ),
                SizedBox(width: GlassTokens.spacingMD),
                Text(
                  isIncome ? 'Add Income' : 'Add Expense',
                  style: AppTheme.headlineLarge.copyWith(
                    color: AppTheme.textPrimary(context),
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close_rounded,
                    color: AppTheme.textTertiary(context),
                  ),
                ),
              ],
            ),
          ),
          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: GlassTokens.spacingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  GlassTextField(
                    controller: _titleController,
                    hint: 'Transaction title',
                    prefixIcon: Icons.edit_rounded,
                  ),
                  SizedBox(height: GlassTokens.spacingMD),

                  // Amount + Currency
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: GlassTextField(
                          controller: _amountController,
                          hint: '0.00',
                          prefixIcon: Icons.attach_money_rounded,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      SizedBox(width: GlassTokens.spacingSM),
                      Expanded(
                        child: GlassCard(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          borderRadius: GlassTokens.radiusMedium,
                          child: DropdownButton<String>(
                            value: _selectedCurrency,
                            isExpanded: true,
                            underline: SizedBox(),
                            dropdownColor: AppTheme.surface(context),
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textPrimary(context),
                            ),
                            items: CurrencyService.currencies.keys
                                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                .toList(),
                            onChanged: (v) => setState(() => _selectedCurrency = v!),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: GlassTokens.spacingLG),

                  // Category selector
                  Text(
                    'Category',
                    style: AppTheme.labelLarge.copyWith(
                      color: AppTheme.textSecondary(context),
                    ),
                  ),
                  SizedBox(height: GlassTokens.spacingSM),
                  SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => SizedBox(width: 10),
                      itemBuilder: (context, i) {
                        final cat = _categories[i];
                        final isSelected = cat == _selectedCategory;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategory = cat),
                          child: AnimatedContainer(
                            duration: GlassTokens.animMedium,
                            width: 76,
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(GlassTokens.radiusMedium),
                              color: isSelected
                                  ? cat.color.withOpacity(0.2)
                                  : AppTheme.glassOverlay(context),
                              border: Border.all(
                                color: isSelected ? cat.color : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(cat.icon, color: cat.color, size: 24),
                                SizedBox(height: 4),
                                Text(
                                  cat.label,
                                  style: AppTheme.labelSmall.copyWith(
                                    color: isSelected
                                        ? cat.color
                                        : AppTheme.textTertiary(context),
                                    fontSize: 9,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: GlassTokens.spacingLG),

                  // Date picker
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) setState(() => _selectedDate = picked);
                    },
                    child: GlassCard(
                      padding: EdgeInsets.all(GlassTokens.spacingMD),
                      borderRadius: GlassTokens.radiusMedium,
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              color: AppTheme.textSecondary(context), size: 20),
                          SizedBox(width: GlassTokens.spacingMD),
                          Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            style: AppTheme.bodyLarge.copyWith(
                              color: AppTheme.textPrimary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: GlassTokens.spacingMD),

                  // Recurring toggle
                  GlassCard(
                    padding: EdgeInsets.symmetric(
                      horizontal: GlassTokens.spacingMD,
                      vertical: GlassTokens.spacingSM,
                    ),
                    borderRadius: GlassTokens.radiusMedium,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.repeat_rounded,
                                    color: AppTheme.textSecondary(context), size: 20),
                                SizedBox(width: GlassTokens.spacingSM),
                                Text(
                                  'Recurring',
                                  style: AppTheme.bodyLarge.copyWith(
                                    color: AppTheme.textPrimary(context),
                                  ),
                                ),
                              ],
                            ),
                            Switch.adaptive(
                              value: _isRecurring,
                              onChanged: (v) => setState(() => _isRecurring = v),
                              activeColor: AppTheme.accent(context),
                            ),
                          ],
                        ),
                        if (_isRecurring) ...[
                          SizedBox(height: GlassTokens.spacingSM),
                          Row(
                            children: [
                              for (final interval in [
                                RecurrenceInterval.weekly,
                                RecurrenceInterval.biweekly,
                                RecurrenceInterval.monthly,
                                RecurrenceInterval.yearly,
                              ])
                                Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(interval.name),
                                    selected: _recurrence == interval,
                                    onSelected: (_) =>
                                        setState(() => _recurrence = interval),
                                    selectedColor: AppTheme.accent(context).withOpacity(0.2),
                                    labelStyle: AppTheme.bodySmall.copyWith(
                                      color: _recurrence == interval
                                          ? AppTheme.accent(context)
                                          : AppTheme.textSecondary(context),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: GlassTokens.spacingMD),

                  // Notes
                  GlassTextField(
                    controller: _notesController,
                    hint: 'Add notes (optional)',
                    prefixIcon: Icons.notes_rounded,
                    maxLines: 2,
                  ),
                  SizedBox(height: GlassTokens.spacingXL),

                  // Submit
                  GlassButton(
                    label: isIncome ? 'Add Income' : 'Add Expense',
                    icon: Icons.check_rounded,
                    isExpanded: true,
                    gradientColors: isIncome ? AppTheme.incomeGradient : AppTheme.expenseGradient,
                    onPressed: _submit,
                  ),
                  SizedBox(height: GlassTokens.spacingXXL),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    final title = _titleController.text.trim();
    final amountStr = _amountController.text.trim();
    if (title.isEmpty || amountStr.isEmpty) return;

    final amount = double.tryParse(amountStr);
    if (amount == null || amount <= 0) return;

    final txn = Transaction(
      id: Uuid().v4(),
      title: title,
      amount: amount,
      type: widget.type,
      category: _selectedCategory,
      date: _selectedDate,
      currencyCode: _selectedCurrency,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      isRecurring: _isRecurring,
      recurrence: _isRecurring ? _recurrence : RecurrenceInterval.none,
      isBusiness: widget.isBusiness,
    );

    context.read<TransactionProvider>().addTransaction(txn);

    // Update budget if expense
    if (widget.type == TransactionType.expense && !widget.isBusiness) {
      context.read<BudgetProvider>().updateSpent(_selectedCategory, amount);
    }

    Navigator.pop(context);
  }
}


