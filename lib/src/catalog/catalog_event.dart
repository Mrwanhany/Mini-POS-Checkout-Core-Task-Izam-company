import 'package:equatable/equatable.dart';

abstract class CatalogEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCatalog extends CatalogEvent {}
