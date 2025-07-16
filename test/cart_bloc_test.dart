import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_mini_pos_task/src/cart/cart_bloc.dart';
import 'package:flutter_mini_pos_task/src/cart/models.dart';
import 'package:flutter_mini_pos_task/src/cart/receipt.dart';
import 'package:flutter_mini_pos_task/src/catalog/item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CartBloc', () {
    late Item coffeeItem;
    late Item teaItem;

    setUp(() {
      coffeeItem = const Item(id: 'p01', name: 'Coffee', price: 2.50);
      teaItem = const Item(id: 'p02', name: 'Tea', price: 2.00);
    });

    test('initial state is empty cart', () {
      final cartBloc = CartBloc();
      expect(cartBloc.state, equals(const CartState.empty()));
      cartBloc.close();
    });

    group('AddItem', () {
      blocTest<CartBloc, CartState>(
        'adds new item to empty cart',
        build: () => CartBloc(),
        act: (bloc) => bloc.add(AddItem(coffeeItem)),
        verify: (bloc) {
          final state = bloc.state;
          expect(state.lines.length, equals(1));
          expect(state.lines.first.item, equals(coffeeItem));
          expect(state.lines.first.quantity, equals(1));
          expect(state.totals.subtotal, equals(2.50));
          expect(state.totals.vat, equals(0.38));
          expect(state.totals.grandTotal, equals(2.88));
        },
      );

      blocTest<CartBloc, CartState>(
        'increments quantity when adding existing item',
        build: () => CartBloc(),
        act: (bloc) {
          bloc.add(AddItem(coffeeItem));
          bloc.add(AddItem(coffeeItem));
        },
        verify: (bloc) {
          final state = bloc.state;
          expect(state.lines.length, equals(1));
          expect(state.lines.first.quantity, equals(2));
          expect(state.totals.subtotal, equals(5.00));
        },
      );
    });

    group('RemoveItem', () {
      blocTest<CartBloc, CartState>(
        'removes item from cart',
        build: () => CartBloc(),
        act: (bloc) {
          bloc.add(AddItem(coffeeItem));
          bloc.add(RemoveItem(coffeeItem));
        },
        verify: (bloc) {
          final state = bloc.state;
          expect(state.lines.length, equals(0));
          expect(state.totals.subtotal, equals(0.0));
        },
      );
    });

    group('ChangeQty', () {
      blocTest<CartBloc, CartState>(
        'changes quantity of existing item',
        build: () => CartBloc(),
        act: (bloc) {
          bloc.add(AddItem(coffeeItem));
          bloc.add(ChangeQty(coffeeItem, 3));
        },
        verify: (bloc) {
          final state = bloc.state;
          expect(state.lines.length, equals(1));
          expect(state.lines.first.quantity, equals(3));
          expect(state.totals.subtotal, equals(7.50));
        },
      );

      blocTest<CartBloc, CartState>(
        'removes item when quantity is set to 0',
        build: () => CartBloc(),
        act: (bloc) {
          bloc.add(AddItem(coffeeItem));
          bloc.add(ChangeQty(coffeeItem, 0));
        },
        verify: (bloc) {
          final state = bloc.state;
          expect(state.lines.length, equals(0));
        },
      );
    });

    group('ChangeDiscount', () {
      blocTest<CartBloc, CartState>(
        'applies discount to item',
        build: () => CartBloc(),
        act: (bloc) {
          bloc.add(AddItem(coffeeItem));
          bloc.add(ChangeDiscount(coffeeItem, 0.1));
        },
        verify: (bloc) {
          final state = bloc.state;
          expect(state.lines.length, equals(1));
          expect(state.lines.first.discount, equals(0.1));
          expect(state.lines.first.lineNet, equals(2.25));
          expect(state.totals.subtotal, equals(2.25));
        },
      );

      blocTest<CartBloc, CartState>(
        'clamps discount to valid range',
        build: () => CartBloc(),
        act: (bloc) {
          bloc.add(AddItem(coffeeItem));
          bloc.add(ChangeDiscount(coffeeItem, 1.5)); // Invalid
        },
        verify: (bloc) {
          final state = bloc.state;
          expect(state.lines.first.discount, equals(1.0));
        },
      );
    });

    group('ClearCart', () {
      blocTest<CartBloc, CartState>(
        'clears all items from cart',
        build: () => CartBloc(),
        act: (bloc) {
          bloc.add(AddItem(coffeeItem));
          bloc.add(AddItem(teaItem));
          bloc.add(ClearCart());
        },
        verify: (bloc) {
          final state = bloc.state;
          expect(state.lines.length, equals(0));
          expect(state.totals.subtotal, equals(0.0));
        },
      );
    });

    group('Business Logic Tests', () {
      blocTest<CartBloc, CartState>(
        'Test 1: Two different items → correct totals',
        build: () => CartBloc(),
        act: (bloc) {
          bloc.add(AddItem(coffeeItem));
          bloc.add(AddItem(teaItem));
        },
        verify: (bloc) {
          final state = bloc.state;
          expect(state.lines.length, equals(2));
          expect(state.totals.subtotal, equals(4.5));
          expect(state.totals.vat, closeTo(0.68, 0.02));
          expect(state.totals.grandTotal, closeTo(5.18, 0.02));
        },
      );

      blocTest<CartBloc, CartState>(
        'Test 2: Qty + discount changes update totals',
        build: () => CartBloc(),
        act: (bloc) {
          bloc.add(AddItem(coffeeItem));
          bloc.add(ChangeQty(coffeeItem, 2));
          bloc.add(ChangeDiscount(coffeeItem, 0.1));
        },
        verify: (bloc) {
          final state = bloc.state;
          expect(state.lines.first.lineNet, equals(4.50));
          expect(state.totals.subtotal, equals(4.50));
          expect(state.totals.vat, closeTo(0.68, 0.02));

          expect(state.totals.grandTotal, closeTo(5.18, 0.02));
        },
      );

      blocTest<CartBloc, CartState>(
        'Test 3: Clearing cart resets state',
        build: () => CartBloc(),
        act: (bloc) {
          bloc.add(AddItem(coffeeItem));
          bloc.add(AddItem(teaItem));
          bloc.add(ClearCart());
        },
        verify: (bloc) {
          final state = bloc.state;
          expect(state, equals(const CartState.empty()));
        },
      );
    });
  });

  group('CartLine', () {
    test('calculates line net correctly', () {
      const item = Item(id: 'p01', name: 'Coffee', price: 2.50);
      const cartLine = CartLine(item: item, quantity: 2, discount: 0.1);

      expect(cartLine.lineNet, equals(4.50)); // 2.50 * 2 * 0.9
    });

    test('supports copyWith', () {
      const item = Item(id: 'p01', name: 'Coffee', price: 2.50);
      const cartLine = CartLine(item: item, quantity: 1);

      final newCartLine = cartLine.copyWith(quantity: 2, discount: 0.1);

      expect(newCartLine.item, equals(item));
      expect(newCartLine.quantity, equals(2));
      expect(newCartLine.discount, equals(0.1));
    });

    test('supports value equality', () {
      const item = Item(id: 'p01', name: 'Coffee', price: 2.50);
      const cartLine1 = CartLine(item: item, quantity: 1);
      const cartLine2 = CartLine(item: item, quantity: 1);
      const cartLine3 = CartLine(item: item, quantity: 2);

      expect(cartLine1, equals(cartLine2));
      expect(cartLine1, isNot(equals(cartLine3)));
    });
  });

  group('CartState', () {
    test('creates empty state correctly', () {
      const emptyState = CartState.empty();

      expect(emptyState.lines, isEmpty);
      expect(emptyState.totals.subtotal, equals(0.0));
      expect(emptyState.totals.vat, equals(0.0));
      expect(emptyState.totals.grandTotal, equals(0.0));
    });

    test('calculates totals correctly from lines', () {
      const item1 = Item(id: 'p01', name: 'Coffee', price: 2.50);
      const item2 = Item(id: 'p02', name: 'Tea', price: 2.00);

      const lines = [
        CartLine(item: item1, quantity: 2), // 5.00
        CartLine(item: item2, quantity: 1, discount: 0.1), // 1.80
      ];

      final state = CartState.fromLines(lines);

      expect(state.totals.subtotal, equals(6.80));
      expect(state.totals.vat, equals(1.02));
      expect(state.totals.grandTotal, equals(7.82));
      expect(state.totals.discount, equals(0.20));
    });
  });

  group('Receipt', () {
    test('buildReceipt creates correct receipt from cart state', () {
      const item = Item(id: 'p01', name: 'Coffee', price: 2.50);
      const cartLine = CartLine(item: item, quantity: 2, discount: 0.1);
      final cartState = CartState.fromLines(const [cartLine]);
      final timestamp = DateTime(2023, 1, 1, 12, 0, 0);

      final receipt = buildReceipt(cartState, timestamp);

      expect(receipt.header.timestamp, equals(timestamp));
      expect(receipt.header.receiptId, contains('R'));
      expect(receipt.lines.length, equals(1));
      expect(receipt.lines.first.itemId, equals('p01'));
      expect(receipt.lines.first.itemName, equals('Coffee'));
      expect(receipt.lines.first.quantity, equals(2));
      expect(receipt.lines.first.discount, equals(0.1));
      expect(receipt.lines.first.lineNet, equals(4.50));
      expect(receipt.totals.subtotal, equals(cartState.totals.subtotal));
      expect(receipt.totals.vat, equals(cartState.totals.vat));
      expect(receipt.totals.grandTotal, equals(cartState.totals.grandTotal));
    });
  });
  String formatReceipt(Receipt receipt) {
    final buffer = StringBuffer();
    buffer.writeln('Receipt ID: ${receipt.header.receiptId}');
    buffer.writeln('Timestamp: ${receipt.header.timestamp}');
    buffer.writeln('\nItems:');
    for (final line in receipt.lines) {
      buffer.writeln('- ${line.itemName} (x${line.quantity})');
      buffer.writeln('  ID: ${line.itemId}');
      buffer.writeln(
          '  Price (after discount): ${line.lineNet.toStringAsFixed(2)}');
      buffer
          .writeln('  Discount: ${(line.discount * 100).toStringAsFixed(1)}%');
    }
    buffer.writeln('\nSubtotal: ${receipt.totals.subtotal.toStringAsFixed(2)}');
    buffer.writeln('VAT (15%): ${receipt.totals.vat.toStringAsFixed(2)}');
    buffer.writeln('Total: ${receipt.totals.grandTotal.toStringAsFixed(2)}');
    return buffer.toString();
  }

  group('Manual Receipt Generation', () {
    test('Prints a sample receipt', () {
      const item = Item(id: 'p01', name: 'Coffee', price: 2.50);
      const cartLine = CartLine(item: item, quantity: 2, discount: 0.1);
      final cartState = CartState.fromLines(const [cartLine]);
      final timestamp = DateTime(2023, 1, 1, 12, 0, 0);
      final receipt = buildReceipt(cartState, timestamp);

      if (kDebugMode) {
        print(formatReceipt(receipt));
      }
    });
  });
}
