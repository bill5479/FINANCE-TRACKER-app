import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fintracker_app/models/user.dart';
import 'package:fintracker_app/providers/auth_provider.dart';
import 'package:fintracker_app/providers/theme_provider.dart';
import 'package:fintracker_app/providers/transaction_provider.dart';
import 'package:fintracker_app/services/currency_service.dart';
import 'package:fintracker_app/services/notification_service.dart';
import 'package:fintracker_app/services/export_service.dart';
import 'package:fintracker_app/theme/app_theme.dart';
import 'package:fintracker_app/theme/glass_tokens.dart';
import 'package:fintracker_app/widgets/glass_app_bar.dart';
import 'package:fintracker_app/widgets/glass_button.dart';
import 'package:fintracker_app/widgets/glass_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = NotificationService.instance.isEnabled;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final transactions = context.watch<TransactionProvider>();
    final user = authProvider.currentUser;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: GlassAppBar(title: 'Settings'),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: GlassTokens.spacingMD),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 940),
                child: Column(
                  children: [
                    GlassCard(
                      padding: const EdgeInsets.all(GlassTokens.spacingXXL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile Settings',
                            style: AppTheme.headlineLarge.copyWith(
                              color: AppTheme.textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: GlassTokens.spacingXL),
                          _FieldBlock(
                            label: 'EMAIL',
                            child: _StaticField(value: user?.email ?? 'demo@example.com'),
                          ),
                          _FieldBlock(
                            label: 'DISPLAY NAME',
                            child: _StaticField(value: user?.name ?? 'Demo User'),
                          ),
                          _FieldBlock(
                            label: 'STARTING BALANCE',
                            helper: 'Local-first setup uses your current personal balance as the visible baseline for this demo.',
                            child: _StaticField(
                              value: CurrencyService.format(
                                transactions.personalBalance,
                                themeProvider.currencyCode,
                              ),
                            ),
                          ),
                          _FieldBlock(
                            label: 'DEFAULT CURRENCY',
                            child: _CurrencySelector(
                              value: themeProvider.currencyCode,
                              onChanged: themeProvider.setCurrency,
                            ),
                          ),
                          _FieldBlock(
                            label: 'THEME MODE',
                            child: _ThemeSelector(
                              mode: themeProvider.themeMode,
                              onChanged: themeProvider.setThemeMode,
                            ),
                          ),
                          _FieldBlock(
                            label: 'NOTIFICATIONS',
                            helper: 'Bill reminders and budget threshold alerts are scheduled locally on-device in this phase.',
                            child: SwitchListTile.adaptive(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                _notificationsEnabled ? 'Enabled' : 'Disabled',
                                style: AppTheme.titleMedium.copyWith(
                                  color: AppTheme.textPrimary(context),
                                ),
                              ),
                              subtitle: Text(
                                _notificationsEnabled
                                    ? 'Budget alerts and due-date reminders are active.'
                                    : 'Notifications are paused for this device.',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.textTertiary(context),
                                ),
                              ),
                              value: _notificationsEnabled,
                              onChanged: (value) async {
                                await NotificationService.instance.setEnabled(value);
                                if (!mounted) return;
                                setState(() => _notificationsEnabled = value);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: GlassTokens.spacingMD),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 820;
                        final team = _TeamCard(authProvider: authProvider);
                        final sync = _SystemCard(
                          title: 'Cloud Sync',
                          subtitle: 'Visible by design, inactive in v1',
                          description:
                              'Cloud sync is intentionally present as a no-op card so teams understand the roadmap without confusing this release with a remote backend.',
                          icon: Icons.cloud_outlined,
                          accent: AppTheme.accent(context),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.warning(context).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'INACTIVE',
                              style: AppTheme.labelSmall.copyWith(
                                color: AppTheme.warning(context),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        );

                        final backup = _SystemCard(
                          title: 'Local Backup & Export',
                          subtitle: 'CSV and PDF snapshots',
                          description:
                              'Export your transactions or invoices anytime. Files are written to the device documents directory for easy local backup.',
                          icon: Icons.file_download_outlined,
                          accent: AppTheme.success(context),
                          trailing: GlassButton(
                            label: 'Export CSV',
                            icon: Icons.table_chart_outlined,
                            small: true,
                            onPressed: () async {
                              final path = await ExportService.exportTransactionsCSV(
                                transactions.transactions,
                              );
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('CSV exported to $path')),
                              );
                            },
                          ),
                        );

                        if (!wide) {
                          return Column(
                            children: [team, const SizedBox(height: GlassTokens.spacingMD), sync, const SizedBox(height: GlassTokens.spacingMD), backup],
                          );
                        }

                        return Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: team),
                                const SizedBox(width: GlassTokens.spacingMD),
                                Expanded(child: sync),
                              ],
                            ),
                            const SizedBox(height: GlassTokens.spacingMD),
                            backup,
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: GlassTokens.spacingXXL)),
      ],
    );
  }
}

class _FieldBlock extends StatelessWidget {
  const _FieldBlock({
    required this.label,
    required this.child,
    this.helper,
  });

  final String label;
  final Widget child;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: GlassTokens.spacingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.labelLarge.copyWith(
              color: AppTheme.textSecondary(context),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: GlassTokens.spacingSM),
          child,
          if (helper != null) ...[
            const SizedBox(height: 8),
            Text(
              helper!,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textTertiary(context),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StaticField extends StatelessWidget {
  const _StaticField({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: GlassTokens.spacingMD,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: AppTheme.glassOverlay(context).withOpacity(0.48),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        value,
        style: AppTheme.bodyLarge.copyWith(
          color: AppTheme.textPrimary(context),
        ),
      ),
    );
  }
}

class _CurrencySelector extends StatelessWidget {
  const _CurrencySelector({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: GlassTokens.spacingMD),
      decoration: BoxDecoration(
        color: AppTheme.glassOverlay(context).withOpacity(0.48),
        borderRadius: BorderRadius.circular(22),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        value: value,
        underline: const SizedBox.shrink(),
        items: CurrencyService.currencies.entries
            .map(
              (entry) => DropdownMenuItem<String>(
                value: entry.key,
                child: Text('${entry.key} (${entry.value.symbol})'),
              ),
            )
            .toList(),
        onChanged: (nextValue) {
          if (nextValue != null) {
            onChanged(nextValue);
          }
        },
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({required this.mode, required this.onChanged});

  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      borderRadius: 24,
      child: Row(
        children: [
          _ThemePill(
            label: 'System',
            selected: mode == ThemeMode.system,
            onTap: () => onChanged(ThemeMode.system),
          ),
          const SizedBox(width: 8),
          _ThemePill(
            label: 'Light',
            selected: mode == ThemeMode.light,
            onTap: () => onChanged(ThemeMode.light),
          ),
          const SizedBox(width: 8),
          _ThemePill(
            label: 'Dark',
            selected: mode == ThemeMode.dark,
            onTap: () => onChanged(ThemeMode.dark),
          ),
        ],
      ),
    );
  }
}

class _ThemePill extends StatelessWidget {
  const _ThemePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: GlassTokens.animMedium,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: selected
                ? AppTheme.glassOverlay(context).withOpacity(0.92)
                : Colors.transparent,
            border: Border.all(
              color: selected
                  ? AppTheme.glassBorder(context)
                  : Colors.transparent,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTheme.titleMedium.copyWith(
                color: selected
                    ? AppTheme.textPrimary(context)
                    : AppTheme.textSecondary(context),
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  const _TeamCard({required this.authProvider});

  final AuthProvider authProvider;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Team Roles',
            style: AppTheme.headlineMedium.copyWith(
              color: AppTheme.textPrimary(context),
            ),
          ),
          const SizedBox(height: GlassTokens.spacingSM),
          Text(
            'Role-based access is enforced visually here: admins manage, editors update, viewers observe.',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary(context),
              height: 1.6,
            ),
          ),
          const SizedBox(height: GlassTokens.spacingLG),
          ...authProvider.users.map(
            (user) => Padding(
              padding: const EdgeInsets.only(bottom: GlassTokens.spacingSM),
              child: _UserRow(
                user: user,
                isCurrent: user.id == authProvider.currentUser?.id,
                onTap: authProvider.canManageUsers && user.id != authProvider.currentUser?.id
                    ? () => authProvider.switchUser(user.id)
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({
    required this.user,
    required this.isCurrent,
    this.onTap,
  });

  final AppUser user;
  final bool isCurrent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (user.role) {
      UserRole.admin => AppTheme.accent(context),
      UserRole.editor => AppTheme.success(context),
      UserRole.viewer => AppTheme.warning(context),
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(GlassTokens.spacingMD),
        decoration: BoxDecoration(
          color: AppTheme.glassOverlay(context).withOpacity(0.45),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withOpacity(0.14),
              child: Text(
                user.name.substring(0, 1),
                style: AppTheme.titleMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: GlassTokens.spacingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        user.name,
                        style: AppTheme.titleMedium.copyWith(
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(width: 6),
                        Text(
                          '(You)',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textTertiary(context),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    user.email,
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
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                user.role.name.toUpperCase(),
                style: AppTheme.labelSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SystemCard extends StatelessWidget {
  const _SystemCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.accent,
    required this.trailing,
  });

  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color accent;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: GlassTokens.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.titleLarge.copyWith(
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textTertiary(context),
                      ),
                    ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
          const SizedBox(height: GlassTokens.spacingMD),
          Text(
            description,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary(context),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

