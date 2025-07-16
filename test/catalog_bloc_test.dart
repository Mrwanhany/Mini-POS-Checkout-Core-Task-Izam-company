// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_mini_pos_task/data/catalog_repo.dart';
import 'package:flutter_mini_pos_task/mini_pos_checkout.dart';
import 'package:flutter_mini_pos_task/src/catalog/catalog_event.dart';
import 'package:flutter_mini_pos_task/src/catalog/catalog_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCatalogRepository extends Mock implements CatalogRepository {}

void main() {
  late MockCatalogRepository mockRepository;

  setUp(() {
    mockRepository = MockCatalogRepository();
  });

  blocTest<CatalogBloc, CatalogState>(
    'emits [CatalogLoading, CatalogError] when repository throws',
    build: () {
      when(() => mockRepository.loadCatalog())
          .thenThrow(Exception('Simulated failure'));
      return CatalogBloc(mockRepository);
    },
    act: (bloc) => bloc.add(LoadCatalog()),
    expect: () => [
      isA<CatalogLoading>(),
      isA<CatalogError>()
          .having((e) => e.message, 'message', contains('Simulated failure')),
    ],
  );
}
