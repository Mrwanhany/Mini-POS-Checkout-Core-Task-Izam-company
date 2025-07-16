import 'package:bloc/bloc.dart';
import 'package:flutter_mini_pos_task/data/catalog_repo.dart';
import 'package:flutter_mini_pos_task/src/catalog/catalog_event.dart';
import 'package:flutter_mini_pos_task/src/catalog/catalog_state.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  final CatalogRepository repository;

  CatalogBloc(this.repository) : super(CatalogInitial()) {
    on<LoadCatalog>(_onLoadCatalog);
  }

  Future<void> _onLoadCatalog(
      LoadCatalog event, Emitter<CatalogState> emit) async {
    emit(CatalogLoading());
    try {
      final items = await repository.loadCatalog();
      emit(CatalogLoaded(items));
    } catch (e) {
      emit(CatalogError(message: 'Failed to load catalog: ${e.toString()}'));
    }
  }
}
