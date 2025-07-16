import 'package:equatable/equatable.dart';
import 'package:flutter_mini_pos_task/mini_pos_checkout.dart';

abstract class CatalogState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CatalogInitial extends CatalogState {}

class CatalogLoading extends CatalogState {}

class CatalogLoaded extends CatalogState {
  /// List of items in the catalog
  final List<Item> items;

  /// Creates a [CatalogLoaded] state with the given [items]
  CatalogLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

/// State when catalog loading fails

class CatalogError extends CatalogState {
  final String message;
  CatalogError({this.message = 'Failed to load catalog'});

  @override
  List<Object?> get props => [message];
}
