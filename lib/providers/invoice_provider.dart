import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:fintracker_app/models/invoice.dart';
import 'package:fintracker_app/services/storage_service.dart';

class InvoiceProvider extends ChangeNotifier {
  List<Invoice> _invoices = [];
  final _uuid = Uuid();
  int _nextInvoiceNum = 1001;

  List<Invoice> get invoices => List.unmodifiable(_invoices);

  List<Invoice> get paidInvoices =>
      _invoices.where((i) => i.status == InvoiceStatus.paid).toList();

  List<Invoice> get pendingInvoices =>
      _invoices.where((i) => i.status == InvoiceStatus.sent || i.status == InvoiceStatus.draft).toList();

  List<Invoice> get overdueInvoices =>
      _invoices.where((i) => i.isOverdue).toList();

  double get totalReceivable =>
      _invoices.where((i) => i.status != InvoiceStatus.paid && i.status != InvoiceStatus.cancelled)
          .fold(0.0, (sum, i) => sum + i.amountDue);

  double get totalCollected =>
      _invoices.fold(0.0, (sum, i) => sum + i.amountPaid);

  InvoiceProvider() {
    _loadInvoices();
    _seedDemoData();
  }

  void _seedDemoData() {
    if (_invoices.isNotEmpty) return;
    final now = DateTime.now();
    _invoices = [
      Invoice(
        id: _uuid.v4(),
        invoiceNumber: 'INV-1001',
        clientName: 'Acme Corporation',
        clientEmail: 'billing@acme.com',
        items: [
          InvoiceItem(description: 'Web Development', quantity: 1, unitPrice: 5000),
          InvoiceItem(description: 'UI/UX Design', quantity: 1, unitPrice: 2500),
        ],
        taxRate: 0.10,
        status: InvoiceStatus.paid,
        issueDate: now.subtract(Duration(days: 30)),
        dueDate: now.subtract(Duration(days: 15)),
        amountPaid: 8250,
      ),
      Invoice(
        id: _uuid.v4(),
        invoiceNumber: 'INV-1002',
        clientName: 'TechStart Inc.',
        clientEmail: 'finance@techstart.io',
        items: [
          InvoiceItem(description: 'Mobile App Development', quantity: 1, unitPrice: 12000),
          InvoiceItem(description: 'API Integration', quantity: 1, unitPrice: 3000),
        ],
        taxRate: 0.10,
        status: InvoiceStatus.sent,
        issueDate: now.subtract(Duration(days: 10)),
        dueDate: now.add(Duration(days: 20)),
        amountPaid: 0,
      ),
      Invoice(
        id: _uuid.v4(),
        invoiceNumber: 'INV-1003',
        clientName: 'Design Studio Co.',
        clientEmail: 'hello@designstudio.co',
        items: [
          InvoiceItem(description: 'Brand Strategy Consulting', quantity: 5, unitPrice: 500),
        ],
        taxRate: 0.08,
        status: InvoiceStatus.sent,
        issueDate: now.subtract(Duration(days: 45)),
        dueDate: now.subtract(Duration(days: 5)),
        amountPaid: 0,
      ),
    ];
    _nextInvoiceNum = 1004;
    _saveInvoices();
    notifyListeners();
  }

  Future<void> _loadInvoices() async {
    final data = await StorageService.instance.load('invoices');
    if (data != null && data is List) {
      _invoices = data.map((j) => Invoice.fromJson(j)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveInvoices() async {
    await StorageService.instance.save('invoices', _invoices.map((i) => i.toJson()).toList());
  }

  String generateInvoiceNumber() {
    return 'INV-${_nextInvoiceNum++}';
  }

  Future<void> addInvoice(Invoice invoice) async {
    _invoices.insert(0, invoice);
    await _saveInvoices();
    notifyListeners();
  }

  Future<void> updateInvoice(Invoice invoice) async {
    final index = _invoices.indexWhere((i) => i.id == invoice.id);
    if (index != -1) {
      _invoices[index] = invoice;
      await _saveInvoices();
      notifyListeners();
    }
  }

  Future<void> markAsPaid(String id) async {
    final index = _invoices.indexWhere((i) => i.id == id);
    if (index != -1) {
      _invoices[index] = _invoices[index].copyWith(
        status: InvoiceStatus.paid,
        amountPaid: _invoices[index].total,
      );
      await _saveInvoices();
      notifyListeners();
    }
  }

  Future<void> removeInvoice(String id) async {
    _invoices.removeWhere((i) => i.id == id);
    await _saveInvoices();
    notifyListeners();
  }
}

