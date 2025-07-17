# Mini POS Checkout Core

A headless checkout engine for POS and ESS applications built with Flutter and BLoC pattern.

## Features

- **Catalog Management**: Load product catalog from JSON assets
- **Cart Operations**: Add/remove items, change quantities, apply discounts
- **Business Logic**: VAT calculation (15%), line totals, grand totals
- **Receipt Generation**: Pure function to generate receipt DTOs
- **Immutable State**: All state objects use value equality
- **Fully Tested**: Comprehensive unit tests with BLoC testing

## Environment

- **Flutter**: 3.29.2
- **Dart**: 3.7.2

## Getting Started

### Installation

```bash
flutter pub get
```

### Running Tests

```bash
flutter test
```

### Running with Coverage

```bash
flutter test --coverage
```

## Architecture

The project follows clean architecture principles with BLoC pattern:

```
lib/
├── src/
│   ├── catalog/
│   │   ├── item.dart          # Item model
│   │   └── catalog_bloc.dart  # Catalog BLoC
│   │   └── catalog_event.dart  # Catalog Events
│   │   └── catalog_state.dart  # Catalog States
│   ├── cart/
│   │   ├── models.dart        # Cart models (CartLine, CartState, etc.)
│   │   ├── cart_bloc.dart     # Cart BLoC
│   │   └── receipt.dart       # Receipt builder
│   └── util/
│       └── money_extension.dart # Money formatting extension
├── main.dart                  # App entry point
└── mini_pos_checkout.dart     # Library exports
```

## Business Rules

- **VAT**: 15% applied to subtotal
- **Line Net**: `price × quantity × (1 - discount%)`
- **Subtotal**: Sum of all line nets
- **Grand Total**: `subtotal + vat`
- **Discount**: Applied per line, clamped between 0.0 and 1.0

## Usage Examples

### Loading Catalog

```dart
final catalogBloc = CatalogBloc();
catalogBloc.add(LoadCatalog());
```

### Cart Operations

```dart
final cartBloc = CartBloc();

// Add items
cartBloc.add(AddItem(coffeeItem));
cartBloc.add(AddItem(teaItem));

// Change quantity
cartBloc.add(ChangeQty(coffeeItem, 2));

// Apply discount
cartBloc.add(ChangeDiscount(coffeeItem, 0.1)); // 10% discount

// Clear cart
cartBloc.add(ClearCart());
```

### Generate Receipt

```dart
final receipt = buildReceipt(cartState, DateTime.now());
```

## Test Coverage

The project includes comprehensive unit tests covering:

1. **Two different items → correct totals**
2. **Quantity + discount changes update totals**  
3. **Clearing cart resets state**
4. **Business logic validation**
5. **Model equality and immutability**
6. **Error handling**

## Implementation Status

### ✅ Completed Requirements

- [x] CatalogBloc with LoadCatalog event
- [x] CartBloc with all required events
- [x] Immutable state with value equality
- [x] Business rules (VAT 15%, line calculations)
- [x] Receipt builder pure function
- [x] Required unit tests (3+)
- [x] Public API design for hidden tests
- [x] Code quality (immutable, documented, analyzable)

### ✅ Nice-to-Have Features

- [x] Money extension (`num.asMoney`)
- [x] 100% test coverage target
- [ ] Undo/redo functionality (not implemented)
- [ ] Hydration with hydrated_bloc (not implemented)

## Time Spent

**Total**: ~4 hours
- Setup and architecture: 1 hour
- Core implementation: 1.5 hours  
- Testing: 1 hour
- Documentation: 30 minutes

## Key Design Decisions

1. **Immutable State**: All models extend Equatable for value equality
2. **Pure Functions**: Receipt builder is a pure function as required
3. **Error Handling**: Comprehensive error states in BLoCs
4. **Money Rounding**: Using `double.parse(value.toStringAsFixed(2))` as suggested
5. **Business Logic**: Centralized in model classes and BLoC event handlers

## Dependencies

- `bloc: ^8.1.3` - State management
- `equatable: ^2.0.5` - Value equality
- `bloc_test: ^9.1.5` - BLoC testing utilities

---

*This project demonstrates clean architecture, BLoC pattern, and comprehensive testing for a production-ready checkout system.*
