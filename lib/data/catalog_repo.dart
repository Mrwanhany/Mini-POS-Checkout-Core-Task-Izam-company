// lib/data/catalog_repository.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_mini_pos_task/mini_pos_checkout.dart';

abstract class CatalogRepository {
  Future<List<Item>> loadCatalog();
}

class AssetCatalogRepository implements CatalogRepository {
  @override
  Future<List<Item>> loadCatalog() async {
    final jsonString = await rootBundle.loadString('assets/catalog.json');
    final List<dynamic> raw = json.decode(jsonString);
    return raw.map((e) => Item.fromJson(e)).toList();
  }
}
