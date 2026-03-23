import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fintracker_app/providers/theme_provider.dart';
import 'package:fintracker_app/providers/transaction_provider.dart';
import 'package:fintracker_app/providers/budget_provider.dart';
import 'package:fintracker_app/providers/invoice_provider.dart';
import 'package:fintracker_app/providers/auth_provider.dart';
import 'package:fintracker_app/screens/splash_screen.dart';
import 'package:fintracker_app/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => InvoiceProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const FinTrackerApp(),
    ),
  );
}

class FinTrackerApp extends StatelessWidget {
  const FinTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'FinTracker',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}

