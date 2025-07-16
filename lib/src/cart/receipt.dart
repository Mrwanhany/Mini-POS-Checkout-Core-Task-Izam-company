import 'package:equatable/equatable.dart';
import 'models.dart';

/// Represents a receipt line item
class ReceiptLine extends Equatable {
  final String itemId;
  final String itemName;
  final double unitPrice;
  final int quantity;
  final double discount;
  final double lineNet;

  /// Creates a [ReceiptLine] with the given parameters
  const ReceiptLine({
    required this.itemId,
    required this.itemName,
    required this.unitPrice,
    required this.quantity,
    required this.discount,
    required this.lineNet,
  });

  @override
  List<Object?> get props =>
      [itemId, itemName, unitPrice, quantity, discount, lineNet];

  @override
  String toString() =>
      'ReceiptLine(itemId: $itemId, itemName: $itemName, quantity: $quantity, lineNet: $lineNet)';
}

/// Represents the header information of a receipt
class ReceiptHeader extends Equatable {
  final DateTime timestamp;
  final String receiptId;

  /// Creates a [ReceiptHeader] with the given [timestamp] and [receiptId]
  const ReceiptHeader({
    required this.timestamp,
    required this.receiptId,
  });

  @override
  List<Object?> get props => [timestamp, receiptId];

  @override
  String toString() =>
      'ReceiptHeader(timestamp: $timestamp, receiptId: $receiptId)';
}

/// Represents the totals section of a receipt
class ReceiptTotals extends Equatable {
  final double subtotal;
  final double vat;
  final double discount;
  final double grandTotal;

  /// Creates [ReceiptTotals] with the given values
  const ReceiptTotals({
    required this.subtotal,
    required this.vat,
    required this.discount,
    required this.grandTotal,
  });

  @override
  List<Object?> get props => [subtotal, vat, discount, grandTotal];

  @override
  String toString() =>
      'ReceiptTotals(subtotal: $subtotal, vat: $vat, discount: $discount, grandTotal: $grandTotal)';
}

/// Represents a complete receipt
class Receipt extends Equatable {
  final ReceiptHeader header;
  final List<ReceiptLine> lines;
  final ReceiptTotals totals;

  /// Creates a [Receipt] with the given [header], [lines], and [totals]
  const Receipt({
    required this.header,
    required this.lines,
    required this.totals,
  });

  @override
  List<Object?> get props => [header, lines, totals];

  @override
  String toString() =>
      'Receipt(header: $header, lines: ${lines.length}, totals: $totals)';
}

/// Builds a receipt from the current cart state
///
/// This is a pure function that takes the current [CartState] and a [DateTime]
/// and returns a [Receipt] DTO that can be used by downstream code for
/// rendering or printing.
Receipt buildReceipt(CartState cartState, DateTime timestamp) {
  // Generate a simple receipt ID based on timestamp
  final String receiptId = 'R${timestamp.millisecondsSinceEpoch}';

  // Create header
  final ReceiptHeader header = ReceiptHeader(
    timestamp: timestamp,
    receiptId: receiptId,
  );

  // Create receipt lines from cart lines
  final List<ReceiptLine> lines = cartState.lines.map((cartLine) {
    return ReceiptLine(
      itemId: cartLine.item.id,
      itemName: cartLine.item.name,
      unitPrice: cartLine.item.price,
      quantity: cartLine.quantity,
      discount: cartLine.discount,
      lineNet: cartLine.lineNet,
    );
  }).toList();

  // Create totals
  final ReceiptTotals totals = ReceiptTotals(
    subtotal: cartState.totals.subtotal,
    vat: cartState.totals.vat,
    discount: cartState.totals.discount,
    grandTotal: cartState.totals.grandTotal,
  );

  return Receipt(
    header: header,
    lines: lines,
    totals: totals,
  );
}
