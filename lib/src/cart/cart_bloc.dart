import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../catalog/item.dart';
import 'models.dart';

// Events
/// Base class for all cart events
abstract class CartEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event to add an item to the cart
class AddItem extends CartEvent {
  /// The item to add
  final Item item;

  /// Creates an [AddItem] event with the given [item]
  AddItem(this.item);

  @override
  List<Object?> get props => [item];
}

/// Event to remove an item from the cart
class RemoveItem extends CartEvent {
  /// The item to remove
  final Item item;

  /// Creates a [RemoveItem] event with the given [item]
  RemoveItem(this.item);

  @override
  List<Object?> get props => [item];
}

/// Event to change the quantity of an item in the cart
class ChangeQty extends CartEvent {
  /// The item to change quantity for
  final Item item;

  /// The new quantity
  final int quantity;

  /// Creates a [ChangeQty] event with the given [item] and [quantity]
  ChangeQty(this.item, this.quantity);

  @override
  List<Object?> get props => [item, quantity];
}

/// Event to change the discount of an item in the cart
class ChangeDiscount extends CartEvent {
  /// The item to change discount for
  final Item item;

  /// The new discount percentage (0.0 to 1.0)
  final double discount;

  /// Creates a [ChangeDiscount] event with the given [item] and [discount]
  ChangeDiscount(this.item, this.discount);

  @override
  List<Object?> get props => [item, discount];
}

/// Event to clear the entire cart
class ClearCart extends CartEvent {}

/// BLoC for managing cart state and operations
// lib/src/cart/cart_bloc.dart

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState.empty()) {
    on<AddItem>(_onAddItem);
    on<RemoveItem>(_onRemoveItem);
    on<ChangeQty>(_onChangeQty);
    on<ChangeDiscount>(_onChangeDiscount);
    on<ClearCart>(_onClearCart);
  }

  void _onAddItem(AddItem event, Emitter<CartState> emit) {
    final lines = List<CartLine>.from(state.lines);
    final idx = lines.indexWhere((l) => l.item == event.item);
    if (idx >= 0) {
      final existing = lines[idx];
      lines[idx] = existing.copyWith(quantity: existing.quantity + 1);
    } else {
      lines.add(CartLine(item: event.item, quantity: 1));
    }
    // CartState.fromLines recalculates subtotal, vat, grandTotal, etc.
    emit(CartState.fromLines(lines));
  }

  void _onRemoveItem(RemoveItem event, Emitter<CartState> emit) {
    final lines = state.lines.where((l) => l.item != event.item).toList();
    emit(CartState.fromLines(lines));
  }

  void _onChangeQty(ChangeQty event, Emitter<CartState> emit) {
    final lines = state.lines
        .map((line) {
          if (line.item == event.item) {
            // drop it if quantity=0
            if (event.quantity == 0) return null;
            return line.copyWith(quantity: event.quantity);
          }
          return line;
        })
        .whereType<CartLine>()
        .toList();

    emit(CartState.fromLines(lines));
  }

  void _onChangeDiscount(ChangeDiscount event, Emitter<CartState> emit) {
    final lines = state.lines.map((line) {
      if (line.item == event.item) {
        // clamp discount between 0.0 and 1.0
        final d = event.discount.clamp(0.0, 1.0);
        return line.copyWith(discount: d);
      }
      return line;
    }).toList();

    emit(CartState.fromLines(lines));
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    emit(const CartState.empty());
  }
}
