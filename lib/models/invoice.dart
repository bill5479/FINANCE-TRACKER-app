enum InvoiceStatus { draft, sent, paid, partial, overdue, cancelled }

class InvoiceItem {
  final String description;
  final int quantity;
  final double unitPrice;

  InvoiceItem({
    required this.description,
    this.quantity = 1,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;

  Map<String, dynamic> toJson() => {
        'description': description,
        'quantity': quantity,
        'unitPrice': unitPrice,
      };

  factory InvoiceItem.fromJson(Map<String, dynamic> json) => InvoiceItem(
        description: json['description'],
        quantity: json['quantity'] ?? 1,
        unitPrice: (json['unitPrice'] as num).toDouble(),
      );
}

class Invoice {
  final String id;
  final String invoiceNumber;
  final String clientName;
  final String? clientEmail;
  final List<InvoiceItem> items;
  final double taxRate;
  final InvoiceStatus status;
  final String currencyCode;
  final DateTime issueDate;
  final DateTime dueDate;
  final double amountPaid;
  final String? notes;
  final DateTime createdAt;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.clientName,
    this.clientEmail,
    required this.items,
    this.taxRate = 0.0,
    this.status = InvoiceStatus.draft,
    this.currencyCode = 'USD',
    required this.issueDate,
    required this.dueDate,
    this.amountPaid = 0.0,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get subtotal => items.fold(0, (sum, item) => sum + item.total);
  double get taxAmount => subtotal * taxRate;
  double get total => subtotal + taxAmount;
  double get amountDue => total - amountPaid;
  bool get isOverdue =>
      DateTime.now().isAfter(dueDate) && status != InvoiceStatus.paid;

  Map<String, dynamic> toJson() => {
        'id': id,
        'invoiceNumber': invoiceNumber,
        'clientName': clientName,
        'clientEmail': clientEmail,
        'items': items.map((i) => i.toJson()).toList(),
        'taxRate': taxRate,
        'status': status.index,
        'currencyCode': currencyCode,
        'issueDate': issueDate.toIso8601String(),
        'dueDate': dueDate.toIso8601String(),
        'amountPaid': amountPaid,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        id: json['id'],
        invoiceNumber: json['invoiceNumber'],
        clientName: json['clientName'],
        clientEmail: json['clientEmail'],
        items: (json['items'] as List)
            .map((i) => InvoiceItem.fromJson(i))
            .toList(),
        taxRate: (json['taxRate'] as num).toDouble(),
        status: InvoiceStatus.values[json['status']],
        currencyCode: json['currencyCode'] ?? 'USD',
        issueDate: DateTime.parse(json['issueDate']),
        dueDate: DateTime.parse(json['dueDate']),
        amountPaid: (json['amountPaid'] as num).toDouble(),
        notes: json['notes'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  Invoice copyWith({
    InvoiceStatus? status,
    double? amountPaid,
    List<InvoiceItem>? items,
  }) =>
      Invoice(
        id: id,
        invoiceNumber: invoiceNumber,
        clientName: clientName,
        clientEmail: clientEmail,
        items: items ?? this.items,
        taxRate: taxRate,
        status: status ?? this.status,
        currencyCode: currencyCode,
        issueDate: issueDate,
        dueDate: dueDate,
        amountPaid: amountPaid ?? this.amountPaid,
        notes: notes,
        createdAt: createdAt,
      );
}
