import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/product.dart';

Future<List<Product>> loadCatalog() async =>
    parseCatalog(await rootBundle.loadString('assets/data/products.json'));

List<Product> parseCatalog(String source) {
  final decoded = jsonDecode(source);
  if (decoded is! List) throw const FormatException('Ürün listesi bekleniyor.');
  final products = decoded
      .map((item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Geçersiz ürün kaydı.');
        }
        return Product.fromJson(item);
      })
      .toList(growable: false);
  if (products.map((p) => p.id).toSet().length != products.length) {
    throw const FormatException('Ürün kimlikleri benzersiz olmalıdır.');
  }
  return products;
}

String normalizeSearch(String value) => value
    .trim()
    .toLowerCase()
    .replaceAll('ı', 'i')
    .replaceAll('i\u0307', 'i')
    .replaceAll('ş', 's')
    .replaceAll('ğ', 'g')
    .replaceAll('ü', 'u')
    .replaceAll('ö', 'o')
    .replaceAll('ç', 'c');

List<Product> filterProducts(
  List<Product> products,
  String query,
  String category,
) {
  final words = normalizeSearch(query).split(RegExp(r'\s+'));
  return products
      .where((p) {
        final text = normalizeSearch(
          '${p.name} ${p.category} ${p.description}',
        );
        return (category == 'Tümü' || p.category == category) &&
            words.every(text.contains);
      })
      .toList(growable: false);
}

String formatPrice(int kurus) {
  final whole = (kurus ~/ 100).toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );
  return '$whole,${(kurus % 100).toString().padLeft(2, '0')} ₺';
}
