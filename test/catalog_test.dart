import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mini_katalog/data/catalog_repository.dart';
import 'package:flutter_mini_katalog/models/cart_item.dart';
import 'package:flutter_mini_katalog/models/product.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late List<Product> products;
  setUpAll(() async => products = await loadCatalog());
  test('12 unique products and all local images load', () async {
    expect(products.length, 12);
    expect(products.map((p) => p.id).toSet().length, 12);
    for (final p in products) {
      expect((await rootBundle.load(p.image)).lengthInBytes, greaterThan(1000));
    }
    expect(
      (await rootBundle.load('assets/images/hero.jpg')).lengthInBytes,
      greaterThan(1000),
    );
  });
  test('Product JSON round trip retains all fields', () {
    for (final p in products) {
      expect(
        Product.fromJson(
          jsonDecode(jsonEncode(p.toJson())) as Map<String, dynamic>,
        ).toJson(),
        p.toJson(),
      );
    }
  });
  test('Malformed data and duplicate IDs are rejected', () {
    expect(
      () => Product.fromJson({...products.first.toJson(), 'priceKurus': -1}),
      throwsFormatException,
    );
    expect(
      () => Product.fromJson({...products.first.toJson(), 'stock': -1}),
      throwsFormatException,
    );
    expect(
      () => Product.fromJson({
        ...products.first.toJson(),
        'image': '../outside.jpg',
      }),
      throwsFormatException,
    );
    expect(
      () => parseCatalog(
        jsonEncode([products.first.toJson(), products.first.toJson()]),
      ),
      throwsFormatException,
    );
    expect(() => parseCatalog('{}'), throwsFormatException);
  });
  test('Search handles Turkish letters, case and whitespace', () {
    expect(filterProducts(products, '  ÇANTA  ', 'Aksesuar').single.id, 'backpack');
    expect(filterProducts(products, 'GÜNEŞ', 'Tümü').single.id, 'sunglasses');
    expect(
      filterProducts(products, 'kirmizi ayakkabi', 'Spor').single.id,
      'sneakers',
    );
  });
  test('Search and category filters intersect', () {
    expect(filterProducts(products, '', 'Teknoloji').length, 3);
    expect(filterProducts(products, 'kulaklik', 'Aksesuar'), isEmpty);
    expect(filterProducts(products, 'no-such-product', 'Tümü'), isEmpty);
  });
  test('Cart calculations use exact integer money', () {
    final item = CartItem(product: products.first, quantity: 3);
    expect(item.totalKurus, 749970);
    expect(formatPrice(item.totalKurus), '7.499,70 ₺');
    expect(formatPrice(0), '0,00 ₺');
    expect(formatPrice(100000001), '1.000.000,01 ₺');
  });
}
