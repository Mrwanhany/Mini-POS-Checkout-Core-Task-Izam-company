import 'package:equatable/equatable.dart';
import '../catalog/item.dart';

/// Represents a line item in the shopping cart
class CartLine extends Equatable {
  /// The product item
  final Item item;

  /// Quantity of the item
  final int quantity;

  /// Discount percentage (0.0 to 1.0)
  final double discount;

  /// Creates a [CartLine] with the given [item], [quantity], and [discount]
  const CartLine({
    required this.item,
    required this.quantity,
    this.discount = 0.0,
  });

  /// Calculates the net amount for this line
  /// Formula: price × qty × (1 – discount%)
  double get lineNet {
    final double discountMultiplier = 1.0 - discount;
    final double result = item.price * quantity * discountMultiplier;
    return double.parse(result.toStringAsFixed(2));
  }

  /// Creates a copy of this [CartLine] with optional parameter changes
  CartLine copyWith({
    Item? item,
    int? quantity,
    double? discount,
  }) {
    return CartLine(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      discount: discount ?? this.discount,
    );
  }

  @override
  List<Object?> get props => [item, quantity, discount];

  @override
  String toString() =>
      'CartLine(item: ${item.name}, quantity: $quantity, discount: $discount)';
}

/// Represents the totals calculation for the cart
class CartTotals extends Equatable {
  /// Subtotal before VAT
  final double subtotal;

  /// VAT amount (15%)
  final double vat;

  /// Discount amount
  final double discount;

  /// Grand total including VAT
  final double grandTotal;

  /// Creates [CartTotals] with the given values
  const CartTotals({
    required this.subtotal,
    required this.vat,
    required this.discount,
    required this.grandTotal,
  });

  /// Creates empty totals (all zeros)
  const CartTotals.empty()
      : subtotal = 0.0,
        vat = 0.0,
        discount = 0.0,
        grandTotal = 0.0;

  @override
  List<Object?> get props => [subtotal, vat, discount, grandTotal];

  @override
  String toString() =>
      'CartTotals(subtotal: $subtotal, vat: $vat, discount: $discount, grandTotal: $grandTotal)';
}

/// Represents the complete state of the shopping cart
class CartState extends Equatable {
  /// List of cart lines
  final List<CartLine> lines;

  /// Calculated totals
  final CartTotals totals;

  /// Creates a [CartState] with the given [lines] and [totals]
  const CartState({
    required this.lines,
    required this.totals,
  });

  /// Creates an empty cart state
  const CartState.empty()
      : lines = const [],
        totals = const CartTotals.empty();

  /// Creates a new [CartState] with calculated totals from the lines
  factory CartState.fromLines(List<CartLine> lines) {
    final subtotalRaw = lines.fold(0.0, (sum, line) => sum + line.lineNet);
    final discountRaw = lines.fold(
      0.0,
      (sum, line) => sum + (line.item.price * line.quantity * line.discount),
    );

    final subtotal = roundTo2(subtotalRaw);
    final vat = roundTo2(subtotal * 0.15);
    final grandTotal = roundTo2(subtotal + vat);
    final discount = roundTo2(discountRaw);

    final CartTotals totals = CartTotals(
      subtotal: subtotal,
      vat: vat,
      discount: discount,
      grandTotal: grandTotal,
    );

    return CartState(
      lines: lines,
      totals: totals,
    );
  }

  @override
  List<Object?> get props => [lines, totals];

  @override
  String toString() => 'CartState(lines: ${lines.length}, totals: $totals)';
}

double roundTo2(double value) {
  return (value * 100).roundToDouble() / 100;
}
