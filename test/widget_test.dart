import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:fintracker_app/providers/auth_provider.dart';
import 'package:fintracker_app/providers/budget_provider.dart';
import 'package:fintracker_app/providers/invoice_provider.dart';
import 'package:fintracker_app/providers/theme_provider.dart';
import 'package:fintracker_app/providers/transaction_provider.dart';
import 'package:fintracker_app/screens/home_screen.dart';

void main() {
  testWidgets('renders desktop shell branding and overview page', (tester) async {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => TransactionProvider()),
          ChangeNotifierProvider(create: (_) => BudgetProvider()),
          ChangeNotifierProvider(create: (_) => InvoiceProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('FINTRACKER'), findsOneWidget);
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Transactions'), findsOneWidget);
  });
}
