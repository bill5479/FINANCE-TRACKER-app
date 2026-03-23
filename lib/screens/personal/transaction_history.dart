import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:fintracker_app/models/transaction.dart';
import 'package:fintracker_app/providers/auth_provider.dart';
import 'package:fintracker_app/providers/theme_provider.dart';
import 'package:fintracker_app/providers/transaction_provider.dart';
import 'package:fintracker_app/screens/personal/add_transaction_sheet.dart';
import 'package:fintracker_app/services/currency_service.dart';
import 'package:fintracker_app/services/export_service.dart';
import 'package:fintracker_app/theme/app_theme.dart';
import 'package:fintracker_app/theme/glass_tokens.dart';
import 'package:fintracker_app/widgets/glass_app_bar.dart';
import 'package:fintracker_app/widgets/glass_button.dart';
import 'package:fintracker_app/widgets/glass_card.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({super.key});

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  final TextEditingController _searchController = TextEditingController();
  _TransactionScopeFilter _scope = _TransactionScopeFilter.all;
  TransactionType? _typeFilter;
  bool _recurringOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final auth = context.watch<AuthProvider>();
    final currency = context.watch<ThemeProvider>().currencyCode;
    final filtered = _filteredTransactions(provider);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: GlassAppBar(
            title: 'Transactions',
            actions: [
              GlassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                borderRadius: 22,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _TransactionScopeFilter.values.map((scope) {
                    final active = _scope == scope;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () => setState(() => _scope = scope),
                        child: AnimatedContainer(
                          duration: GlassTokens.animMedium,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: active
                                ? AppTheme.glassOverlay(context).withOpacity(0.95)
                                : Colors.transparent,
                            border: Border.all(
                              color: active
                                  ? AppTheme.glassBorder(context)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Text(
                            scope.label,
                            style: AppTheme.titleMedium.copyWith(
                              color: active
                                  ? AppTheme.textPrimary(context)
                                  : AppTheme.textSecondary(context),
                              fontWeight:
                                  active ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              GlassButton(
                label: 'Export',
                icon: Icons.file_download_outlined,
                small: true,
                onPressed: () async {
                  final path = await ExportService.exportTransactionsCSV(filtered);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('CSV exported to $path')),
                  );
                },
              ),
              if (auth.canEdit)
                GlassButton(
                  label: 'Add Transaction',
                  icon: Icons.add_rounded,
                  small: true,
                  gradientColors: AppTheme.accentGradient,
                  onPressed: _showCreateMenu,
                ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: GlassTokens.spacingMD),
            child: GlassCard(
              padding: const EdgeInsets.all(GlassTokens.spacingLG),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: GlassTokens.spacingMD,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.glassOverlay(context).withOpacity(0.55),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              icon: Icon(
                                Icons.search_rounded,
                                color: AppTheme.textTertiary(context),
                              ),
                              hintText: 'Search description or category...',
                              hintStyle: AppTheme.bodyLarge.copyWith(
                                color: AppTheme.textTertiary(context),
                              ),
                            ),
                            style: AppTheme.bodyLarge.copyWith(
                              color: AppTheme.textPrimary(context),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: GlassTokens.spacingMD),
                      GestureDetector(
                        onTap: _showAdvancedFilters,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: GlassTokens.spacingLG,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: AppTheme.glassOverlay(context).withOpacity(0.6),
                            border: Border.all(
                              color: AppTheme.glassBorder(context),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.filter_alt_outlined,
                                color: AppTheme.textSecondary(context),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Advanced Filters',
                                style: AppTheme.titleMedium.copyWith(
                                  color: AppTheme.textSecondary(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: GlassTokens.spacingLG),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final showTable = constraints.maxWidth >= 900;
                      if (!showTable) {
                        return Column(
                          children: filtered
                              .map(
                                (transaction) => Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: GlassTokens.spacingSM,
                                  ),
                                  child: _MobileTransactionCard(
                                    transaction: transaction,
                                    currency: currency,
                                    canDelete: auth.canDelete,
                                    onDelete: () => provider.removeTransaction(transaction.id),
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      }

                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: GlassTokens.spacingMD,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                _headerCell(context, 'DATE', flex: 2),
                                _headerCell(context, 'DESCRIPTION', flex: 4),
                                _headerCell(context, 'CATEGORY', flex: 3),
                                _headerCell(context, 'CONTEXT', flex: 2),
                                _headerCell(context, 'AMOUNT', flex: 2, alignEnd: true),
                                _headerCell(context, 'ACTIONS', flex: 1, alignEnd: true),
                              ],
                            ),
                          ),
                          Divider(color: AppTheme.glassBorder(context), height: 1),
                          ...filtered.map(
                            (transaction) => _DesktopTransactionRow(
                              transaction: transaction,
                              currency: currency,
                              canDelete: auth.canDelete,
                              onDelete: () => provider.removeTransaction(transaction.id),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: GlassTokens.spacingXXL,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long_rounded,
                            size: 56,
                            color: AppTheme.textTertiary(context),
                          ),
                          const SizedBox(height: GlassTokens.spacingMD),
                          Text(
                            'No transactions found',
                            style: AppTheme.headlineMedium.copyWith(
                              color: AppTheme.textSecondary(context),
                            ),
                          ),
                          const SizedBox(height: GlassTokens.spacingSM),
                          Text(
                            'Try a different scope or loosen the search terms.',
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
        const SliverToBoxAdapter(child: SizedBox(height: GlassTokens.spacingXXL)),
      ],
    );
  }

  Widget _headerCell(BuildContext context, String text,
      {required int flex, bool alignEnd = false}) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          text,
          style: AppTheme.labelLarge.copyWith(
            color: AppTheme.textSecondary(context),
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  List<Transaction> _filteredTransactions(TransactionProvider provider) {
    var items = provider.transactions.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    switch (_scope) {
      case _TransactionScopeFilter.personal:
        items = items.where((transaction) => !transaction.isBusiness).toList();
        break;
      case _TransactionScopeFilter.business:
        items = items.where((transaction) => transaction.isBusiness).toList();
        break;
      case _TransactionScopeFilter.all:
        break;
    }

    if (_typeFilter != null) {
      items = items
          .where((transaction) => transaction.type == _typeFilter)
          .toList();
    }

    if (_recurringOnly) {
      items = items.where((transaction) => transaction.isRecurring).toList();
    }

    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      items = items.where((transaction) {
        final text = [
          transaction.title,
          transaction.category.label,
          transaction.notes ?? '',
          transaction.isBusiness ? 'business' : 'personal',
        ].join(' ').toLowerCase();
        return text.contains(query);
      }).toList();
    }

    return items;
  }

  void _showAdvancedFilters() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Advanced Filters',
                      style: AppTheme.headlineMedium.copyWith(
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: GlassTokens.spacingLG),
                    Text(
                      'TYPE',
                      style: AppTheme.labelLarge.copyWith(
                        color: AppTheme.textTertiary(context),
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: GlassTokens.spacingSM),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _FilterChipData(label: 'All', value: null),
                        _FilterChipData(label: 'Income', value: TransactionType.income),
                        _FilterChipData(label: 'Expense', value: TransactionType.expense),
                      ].map((data) {
                        final active = data.value == _typeFilter;
                        return ChoiceChip(
                          label: Text(data.label),
                          selected: active,
                          onSelected: (_) {
                            setModalState(() => _typeFilter = data.value);
                            setState(() {});
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: GlassTokens.spacingLG),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Recurring only',
                        style: AppTheme.titleMedium.copyWith(
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      subtitle: Text(
                        'Show automated or scheduled transactions only',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textTertiary(context),
                        ),
                      ),
                      value: _recurringOnly,
                      onChanged: (value) {
                        setModalState(() => _recurringOnly = value);
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: GlassTokens.spacingMD),
                    GlassButton(
                      label: 'Reset Filters',
                      icon: Icons.refresh_rounded,
                      isExpanded: true,
                      onPressed: () {
                        setModalState(() {
                          _typeFilter = null;
                          _recurringOnly = false;
                        });
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCreateMenu() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final businessDefault = _scope == _TransactionScopeFilter.business;
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
                _CreateTile(
                  icon: Icons.arrow_upward_rounded,
                  title: 'New income',
                  subtitle: businessDefault
                      ? 'Log revenue, consulting, or collections'
                      : 'Log salary, freelance, or other income',
                  color: AppTheme.success(context),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showAddTransactionSheet(TransactionType.income, businessDefault);
                  },
                ),
                const SizedBox(height: GlassTokens.spacingSM),
                _CreateTile(
                  icon: Icons.arrow_downward_rounded,
                  title: 'New expense',
                  subtitle: businessDefault
                      ? 'Log marketing, payroll, software, or office costs'
                      : 'Log groceries, rent, subscriptions, or daily spending',
                  color: AppTheme.error(context),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showAddTransactionSheet(TransactionType.expense, businessDefault);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddTransactionSheet(TransactionType type, bool isBusiness) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTransactionSheet(type: type, isBusiness: isBusiness),
    );
  }
}

class _DesktopTransactionRow extends StatelessWidget {
  const _DesktopTransactionRow({
    required this.transaction,
    required this.currency,
    required this.canDelete,
    required this.onDelete,
  });

  final Transaction transaction;
  final String currency;
  final bool canDelete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GlassTokens.spacingMD,
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
            flex: 2,
            child: Text(
              DateFormat('MMM dd, yyyy').format(transaction.date),
              style: AppTheme.bodyLarge.copyWith(
                color: AppTheme.textSecondary(context),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: transaction.category.color.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    transaction.category.icon,
                    color: transaction.category.color,
                    size: 19,
                  ),
                ),
                const SizedBox(width: GlassTokens.spacingMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        style: AppTheme.titleLarge.copyWith(
                          color: AppTheme.textPrimary(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (transaction.isRecurring)
                        Text(
                          'Recurring ${transaction.recurrence.name}',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textTertiary(context),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: transaction.category.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  transaction.category.label,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary(context),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              transaction.isBusiness ? 'Business' : 'Personal',
              style: AppTheme.titleMedium.copyWith(
                color: transaction.isBusiness
                    ? AppTheme.accent(context)
                    : AppTheme.success(context),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${isIncome ? '+' : '-'}${CurrencyService.format(transaction.amount, currency)}',
                style: AppTheme.titleLarge.copyWith(
                  color: isIncome
                      ? AppTheme.success(context)
                      : AppTheme.error(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: canDelete
                  ? IconButton(
                      onPressed: onDelete,
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: AppTheme.textTertiary(context),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileTransactionCard extends StatelessWidget {
  const _MobileTransactionCard({
    required this.transaction,
    required this.currency,
    required this.canDelete,
    required this.onDelete,
  });

  final Transaction transaction;
  final String currency;
  final bool canDelete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    return GlassCard(
      padding: const EdgeInsets.all(GlassTokens.spacingMD),
      borderRadius: 26,
      child: Column(
        children: [
          Row(
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
                    ),
                    Text(
                      '${transaction.category.label} • ${transaction.isBusiness ? 'Business' : 'Personal'}',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textTertiary(context),
                      ),
                    ),
                  ],
                ),
              ),
              if (canDelete)
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: AppTheme.textTertiary(context),
                  ),
                ),
            ],
          ),
          const SizedBox(height: GlassTokens.spacingSM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMM dd, yyyy').format(transaction.date),
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary(context),
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
        ],
      ),
    );
  }
}

class _CreateTile extends StatelessWidget {
  const _CreateTile({
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
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppTheme.textTertiary(context),
          ),
        ],
      ),
    );
  }
}

class _FilterChipData {
  const _FilterChipData({required this.label, required this.value});

  final String label;
  final TransactionType? value;
}

enum _TransactionScopeFilter {
  all('All'),
  personal('Personal'),
  business('Business');

  const _TransactionScopeFilter(this.label);
  final String label;
}

