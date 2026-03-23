import 'dart:io';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:fintracker_app/models/transaction.dart';
import 'package:fintracker_app/models/invoice.dart';
import 'package:fintracker_app/services/currency_service.dart';
import 'package:intl/intl.dart';

class ExportService {
  /// Export transactions to CSV
  static Future<String> exportTransactionsCSV(List<Transaction> transactions) async {
    final rows = <List<dynamic>>[
      ['Date', 'Title', 'Type', 'Category', 'Amount', 'Currency', 'Recurring', 'Business', 'Notes'],
    ];
    for (final t in transactions) {
      rows.add([
        DateFormat('yyyy-MM-dd').format(t.date),
        t.title,
        t.type == TransactionType.income ? 'Income' : 'Expense',
        t.category.label,
        t.amount.toStringAsFixed(2),
        t.currencyCode,
        t.isRecurring ? 'Yes' : 'No',
        t.isBusiness ? 'Yes' : 'No',
        t.notes ?? '',
      ]);
    }
    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/fintracker_transactions_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv');
    await file.writeAsString(csv);
    return file.path;
  }

  /// Export P&L report to PDF
  static Future<String> exportPnLReport({
    required List<Transaction> transactions,
    required String currencyCode,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();

    final filtered = transactions.where((t) =>
        t.date.isAfter(startDate.subtract(Duration(days: 1))) &&
        t.date.isBefore(endDate.add(Duration(days: 1)))).toList();

    final totalIncome = filtered
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpense = filtered
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final netPnL = totalIncome - totalExpense;

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(40),
      build: (context) => [
        pw.Header(
          level: 0,
          child: pw.Text('FinTracker Profit and Loss Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          '${DateFormat('MMM dd, yyyy').format(startDate)} â€” ${DateFormat('MMM dd, yyyy').format(endDate)}',
          style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 24),
        pw.Container(
          padding: pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildPdfStat('Total Income', CurrencyService.format(totalIncome, currencyCode), PdfColors.green700),
              _buildPdfStat('Total Expenses', CurrencyService.format(totalExpense, currencyCode), PdfColors.red700),
              _buildPdfStat(
                  'Net P&L',
                  CurrencyService.format(netPnL, currencyCode),
                  netPnL >= 0 ? PdfColors.green700 : PdfColors.red700),
            ],
          ),
        ),
        pw.SizedBox(height: 24),
        pw.Header(level: 1, child: pw.Text('Transaction Details')),
        pw.Table.fromTextArray(
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
          cellStyle: pw.TextStyle(fontSize: 9),
          headerDecoration: pw.BoxDecoration(color: PdfColors.grey200),
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.centerLeft,
            2: pw.Alignment.centerLeft,
            3: pw.Alignment.centerLeft,
            4: pw.Alignment.centerRight,
          },
          headers: ['Date', 'Title', 'Type', 'Category', 'Amount'],
          data: filtered
              .map((t) => [
                    DateFormat('MMM dd').format(t.date),
                    t.title,
                    t.type == TransactionType.income ? 'Income' : 'Expense',
                    t.category.label,
                    CurrencyService.format(t.amount, currencyCode),
                  ])
              .toList(),
        ),
      ],
    ));

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/fintracker_pnl_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  /// Export invoice to PDF
  static Future<String> exportInvoicePDF(Invoice invoice) async {
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(40),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('INVOICE',
                      style: pw.TextStyle(
                          fontSize: 32, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo)),
                  pw.SizedBox(height: 4),
                  pw.Text(invoice.invoiceNumber,
                      style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('FinTracker', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  pw.Text('finance@fintracker.app', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                ],
              ),
            ],
          ),
          pw.Divider(thickness: 2, color: PdfColors.indigo),
          pw.SizedBox(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Bill To:', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                  pw.Text(invoice.clientName, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  if (invoice.clientEmail != null)
                    pw.Text(invoice.clientEmail!, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Issue Date: ${DateFormat('MMM dd, yyyy').format(invoice.issueDate)}',
                      style: pw.TextStyle(fontSize: 10)),
                  pw.Text('Due Date: ${DateFormat('MMM dd, yyyy').format(invoice.dueDate)}',
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Container(
                    padding: pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: invoice.status == InvoiceStatus.paid
                          ? PdfColors.green100
                          : invoice.isOverdue
                              ? PdfColors.red100
                              : PdfColors.orange100,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      invoice.status.name.toUpperCase(),
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 24),
          pw.Table.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            cellStyle: pw.TextStyle(fontSize: 10),
            headerDecoration: pw.BoxDecoration(color: PdfColors.indigo50),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.centerRight,
              3: pw.Alignment.centerRight,
            },
            headers: ['Description', 'Qty', 'Unit Price', 'Total'],
            data: invoice.items
                .map((item) => [
                      item.description,
                      item.quantity.toString(),
                      CurrencyService.format(item.unitPrice, invoice.currencyCode),
                      CurrencyService.format(item.total, invoice.currencyCode),
                    ])
                .toList(),
          ),
          pw.SizedBox(height: 16),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Container(
              width: 200,
              child: pw.Column(
                children: [
                  _buildInvoiceLine('Subtotal', CurrencyService.format(invoice.subtotal, invoice.currencyCode)),
                  if (invoice.taxRate > 0)
                    _buildInvoiceLine(
                        'Tax (${(invoice.taxRate * 100).toStringAsFixed(0)}%)',
                        CurrencyService.format(invoice.taxAmount, invoice.currencyCode)),
                  pw.Divider(),
                  _buildInvoiceLine('Total', CurrencyService.format(invoice.total, invoice.currencyCode), bold: true),
                  if (invoice.amountPaid > 0)
                    _buildInvoiceLine('Paid', CurrencyService.format(invoice.amountPaid, invoice.currencyCode)),
                  _buildInvoiceLine('Amount Due', CurrencyService.format(invoice.amountDue, invoice.currencyCode),
                      bold: true),
                ],
              ),
            ),
          ),
          if (invoice.notes != null) ...[
            pw.SizedBox(height: 24),
            pw.Text('Notes:', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
            pw.Text(invoice.notes!, style: pw.TextStyle(fontSize: 10)),
          ],
        ],
      ),
    ));

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/fintracker_invoice_${invoice.invoiceNumber}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  static pw.Widget _buildPdfStat(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
        pw.SizedBox(height: 4),
        pw.Text(value, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: color)),
      ],
    );
  }

  static pw.Widget _buildInvoiceLine(String label, String value, {bool bold = false}) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 10, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ],
      ),
    );
  }
}




