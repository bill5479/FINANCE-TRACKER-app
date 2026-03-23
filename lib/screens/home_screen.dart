import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fintracker_app/providers/auth_provider.dart';
import 'package:fintracker_app/providers/theme_provider.dart';
import 'package:fintracker_app/screens/business/business_dashboard.dart';
import 'package:fintracker_app/screens/business/invoice_screen.dart';
import 'package:fintracker_app/screens/business/pnl_report_screen.dart';
import 'package:fintracker_app/screens/personal/budget_screen.dart';
import 'package:fintracker_app/screens/personal/personal_dashboard.dart';
import 'package:fintracker_app/screens/personal/transaction_history.dart';
import 'package:fintracker_app/screens/settings/settings_screen.dart';
import 'package:fintracker_app/theme/app_theme.dart';
import 'package:fintracker_app/theme/glass_tokens.dart';
import 'package:fintracker_app/widgets/animated_gradient_bg.dart';
import 'package:fintracker_app/widgets/glass_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const _sections = [
    _ShellSection('Personal', Icons.dashboard_customize_outlined, Icons.dashboard_customize_rounded),
    _ShellSection('Business', Icons.work_outline_rounded, Icons.work_rounded),
    _ShellSection('Transactions', Icons.receipt_long_outlined, Icons.receipt_long_rounded),
    _ShellSection('Budgets', Icons.pie_chart_outline_rounded, Icons.pie_chart_rounded),
    _ShellSection('Invoices', Icons.description_outlined, Icons.description_rounded),
    _ShellSection('Reports', Icons.bar_chart_outlined, Icons.bar_chart_rounded),
    _ShellSection('Settings', Icons.settings_outlined, Icons.settings_rounded),
  ];

  static const _pages = [
    PersonalDashboard(),
    BusinessDashboard(),
    TransactionHistory(),
    BudgetScreen(),
    InvoiceScreen(),
    PnLReportScreen(),
    SettingsScreen(),
  ];

  void _select(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
    if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
    ));

    return LayoutBuilder(
      builder: (context, constraints) {
        final page = KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _pages[_currentIndex],
        );

        if (constraints.maxWidth >= 960) {
          return Scaffold(
            backgroundColor: AppTheme.bg(context),
            body: AnimatedGradientBg(
              child: SafeArea(
                child: Row(
                  children: [
                    _DesktopSidebar(
                      currentIndex: _currentIndex,
                      sections: _sections,
                      onSelect: _select,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 16, 18, 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: AnimatedSwitcher(
                            duration: GlassTokens.animMedium,
                            child: page,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppTheme.bg(context),
          drawer: Drawer(
            backgroundColor: AppTheme.bg(context),
            child: _MobileSidebar(
              currentIndex: _currentIndex,
              sections: _sections,
              onSelect: _select,
            ),
          ),
          body: AnimatedGradientBg(
            child: Stack(
              children: [
                AnimatedSwitcher(
                  duration: GlassTokens.animMedium,
                  child: page,
                ),
                SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Builder(
                        builder: (context) {
                          return GestureDetector(
                            onTap: () => Scaffold.of(context).openDrawer(),
                            child: GlassCard(
                              padding: const EdgeInsets.all(14),
                              borderRadius: GlassTokens.radiusMedium,
                              child: Icon(
                                Icons.menu_rounded,
                                color: AppTheme.textPrimary(context),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({
    required this.currentIndex,
    required this.sections,
    required this.onSelect,
  });

  final int currentIndex;
  final List<_ShellSection> sections;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return SizedBox(
      width: 320,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
        child: Column(
          children: [
            GlassCard(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              borderRadius: 30,
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(colors: AppTheme.accentGradient),
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'FINTRACKER',
                      style: AppTheme.headlineMedium.copyWith(
                        color: AppTheme.textPrimary(context),
                        letterSpacing: 3.4,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                borderRadius: 34,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        itemCount: sections.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final section = sections[index];
                          final active = index == currentIndex;
                          return GestureDetector(
                            onTap: () => onSelect(index),
                            child: AnimatedContainer(
                              duration: GlassTokens.animMedium,
                              curve: Curves.easeOutCubic,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                color: active
                                    ? AppTheme.glassOverlay(context).withOpacity(0.9)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: active
                                      ? AppTheme.glassBorder(context)
                                      : Colors.transparent,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    active ? section.activeIcon : section.icon,
                                    color: active
                                        ? AppTheme.accent(context)
                                        : AppTheme.textSecondary(context),
                                  ),
                                  const SizedBox(width: 14),
                                  Text(
                                    section.label,
                                    style: AppTheme.titleMedium.copyWith(
                                      color: active
                                          ? AppTheme.accent(context)
                                          : AppTheme.textSecondary(context),
                                      fontWeight:
                                          active ? FontWeight.w700 : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      borderRadius: 26,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor:
                                AppTheme.accent(context).withOpacity(0.12),
                            child: Text(
                              (user?.name ?? 'Demo').substring(0, 1),
                              style: AppTheme.titleMedium.copyWith(
                                color: AppTheme.accent(context),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name ?? 'Demo User',
                                  style: AppTheme.titleMedium.copyWith(
                                    color: AppTheme.textPrimary(context),
                                  ),
                                ),
                                Text(
                                  user?.email ?? 'demo@example.com',
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
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: auth.logout,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          color: Colors.white.withOpacity(0.04),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.logout_rounded,
                                color: AppTheme.textSecondary(context)),
                            const SizedBox(width: 14),
                            Text(
                              'Sign Out',
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileSidebar extends StatelessWidget {
  const _MobileSidebar({
    required this.currentIndex,
    required this.sections,
    required this.onSelect,
  });

  final int currentIndex;
  final List<_ShellSection> sections;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'FINTRACKER',
            style: AppTheme.headlineLarge.copyWith(
              color: AppTheme.textPrimary(context),
              letterSpacing: 3.2,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 18),
          ...sections.asMap().entries.map((entry) {
            final index = entry.key;
            final section = entry.value;
            final active = currentIndex == index;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                borderRadius: 24,
                onTap: () => onSelect(index),
                child: Row(
                  children: [
                    Icon(
                      active ? section.activeIcon : section.icon,
                      color: active
                          ? AppTheme.accent(context)
                          : AppTheme.textSecondary(context),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      section.label,
                      style: AppTheme.titleMedium.copyWith(
                        color: active
                            ? AppTheme.accent(context)
                            : AppTheme.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
          GlassCard(
            padding: const EdgeInsets.all(16),
            borderRadius: 24,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppTheme.accent(context).withOpacity(0.12),
                  child: Text(
                    (user?.name ?? 'Demo').substring(0, 1),
                    style: AppTheme.titleMedium.copyWith(
                      color: AppTheme.accent(context),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.name ?? 'Demo User',
                          style: AppTheme.titleMedium.copyWith(
                              color: AppTheme.textPrimary(context))),
                      Text(user?.email ?? 'demo@example.com',
                          style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textTertiary(context))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            onTap: auth.logout,
            leading: Icon(Icons.logout_rounded,
                color: AppTheme.textSecondary(context)),
            title: Text('Sign Out',
                style: AppTheme.titleMedium.copyWith(
                    color: AppTheme.textSecondary(context))),
          ),
        ],
      ),
    );
  }
}

class _ShellSection {
  const _ShellSection(this.label, this.icon, this.activeIcon);

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

