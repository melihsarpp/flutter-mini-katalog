import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_mini_katalog/main.dart';
import 'package:flutter_mini_katalog/data/catalog_repository.dart';
import 'package:flutter_mini_katalog/models/product.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late List<Product> products;
  setUpAll(() async => products = await loadCatalog());
  Future<void> start(
    WidgetTester tester, {
    List<Product>? data,
    Size size = const Size(390, 844),
    double scale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      MiniCatalogApp(loadProducts: () async => data ?? products),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String key) async {
    if (key.startsWith('product-') &&
        find.byKey(ValueKey(key)).evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        find.byKey(ValueKey(key)),
        200,
        scrollable: find
            .descendant(
              of: find.byKey(const ValueKey('catalog-scroll')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
    }
    await tester.ensureVisible(find.byKey(ValueKey(key)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ValueKey(key)));
    await tester.pumpAndSettle();
  }

  String total(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const ValueKey('cart-total'))).data!;

  testWidgets('Typing from home preserves focus, search and clear work', (
    tester,
  ) async {
    await start(tester);
    expect(find.text('mini.'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('catalog-search')), 's');
    await tester.pumpAndSettle();
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus,
      isTrue,
    );
    await tester.enterText(
      find.byKey(const ValueKey('catalog-search')),
      'canta',
    );
    await tester.pumpAndSettle();
    expect(find.text('Kanvas Omuz Çantası'), findsOneWidget);
    expect(find.text('Studio Kulaklık'), findsNothing);
    await tester.enterText(
      find.byKey(const ValueKey('catalog-search')),
      'bulunmayan',
    );
    await tester.pumpAndSettle();
    expect(find.text('Aradığını bulamadık'), findsOneWidget);
    await tester.tap(find.text('Filtreleri temizle'));
    await tester.pumpAndSettle();
    expect(find.text('12 ürün keşfetmeni bekliyor'), findsOneWidget);
  });
  testWidgets('Grid, list, category filter and banner navigation work', (
    tester,
  ) async {
    await start(tester);
    await tap(tester, 'hero-cta');
    expect(find.text('4 ürün keşfetmeni bekliyor'), findsOneWidget);
    await tap(tester, 'category-Teknoloji');
    expect(find.text('3 ürün keşfetmeni bekliyor'), findsOneWidget);
    await tap(tester, 'view-list');
    expect(find.byKey(const ValueKey('product-list')), findsOneWidget);
    await tap(tester, 'view-grid');
    expect(find.byKey(const ValueKey('product-grid')), findsOneWidget);
  });
  testWidgets('Detail back preserves category and search', (tester) async {
    await start(tester);
    await tap(tester, 'nav-products');
    await tap(tester, 'category-Teknoloji');
    await tester.enterText(
      find.byKey(const ValueKey('catalog-search')),
      'kulaklik',
    );
    await tester.pumpAndSettle();
    await tap(tester, 'product-headphones');
    expect(find.byKey(const ValueKey('detail-name')), findsOneWidget);
    await tap(tester, 'detail-back');
    expect(find.text('1 ürün keşfetmeni bekliyor'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('catalog-search')))
          .controller!
          .text,
      'kulaklik',
    );
  });
  testWidgets(
    'Repeated additions merge; quantities, multiple products and removal update total',
    (tester) async {
      await start(tester);
      await tap(tester, 'nav-products');
      await tap(tester, 'product-headphones');
      await tap(tester, 'add-to-cart');
      await tap(tester, 'add-to-cart');
      await tap(tester, 'detail-back');
      await tap(tester, 'product-watch');
      await tap(tester, 'add-to-cart');
      await tap(tester, 'detail-cart');
      await tester.ensureVisible(find.byKey(const ValueKey('cart-total')));
      expect(total(tester), '6.199,70 ₺');
      await tester.ensureVisible(
        find.byTooltip('Studio Kulaklık adedini artır'),
      );
      await tester.tap(find.byTooltip('Studio Kulaklık adedini artır'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('cart-total')));
      expect(total(tester), '8.699,60 ₺');
      await tester.ensureVisible(
        find.byTooltip('Studio Kulaklık adedini azalt'),
      );
      await tester.tap(find.byTooltip('Studio Kulaklık adedini azalt'));
      await tester.pumpAndSettle();
      await tap(tester, 'remove-headphones');
      expect(total(tester), '1.199,90 ₺');
      await tap(tester, 'remove-watch');
      expect(find.text('Sepetin henüz boş'), findsOneWidget);
    },
  );
  testWidgets(
    'Stock limits apply across repeated additions; decrement to zero removes',
    (tester) async {
      await start(
        tester,
        data: [
          Product.fromJson({...products.first.toJson(), 'stock': 1}),
        ],
      );
      await tap(tester, 'nav-products');
      await tap(tester, 'product-headphones');
      await tap(tester, 'add-to-cart');
      await tap(tester, 'add-to-cart');
      expect(
        find.text('Bu üründen en fazla 1 adet ekleyebilirsin.'),
        findsOneWidget,
      );
      await tap(tester, 'detail-cart');
      expect(
        tester
            .widget<IconButton>(
              find.byWidgetPredicate(
                (widget) =>
                    widget is IconButton &&
                    widget.tooltip == 'Studio Kulaklık adedini artır',
              ),
            )
            .onPressed,
        isNull,
      );
      await tester.tap(find.byTooltip('Studio Kulaklık adedini azalt'));
      await tester.pumpAndSettle();
      expect(find.text('Sepetin henüz boş'), findsOneWidget);
    },
  );
  testWidgets('Out-of-stock products cannot be added', (tester) async {
    await start(
      tester,
      data: [
        Product.fromJson({...products.first.toJson(), 'stock': 0}),
      ],
    );
    await tap(tester, 'nav-products');
    await tap(tester, 'product-headphones');
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey('add-to-cart')))
          .onPressed,
      isNull,
    );
  });
  testWidgets('Loading failure can be retried', (tester) async {
    var attempts = 0;
    await tester.pumpWidget(
      MiniCatalogApp(
        loadProducts: () async {
          if (++attempts == 1) throw const FormatException('test');
          return products;
        },
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Katalog yüklenemedi'), findsOneWidget);
    await tester.tap(find.text('Yeniden dene'));
    await tester.pumpAndSettle();
    expect(find.text('mini.'), findsOneWidget);
  });
  for (final config in [
    (const Size(320, 640), 1.0),
    (const Size(390, 844), 1.0),
    (const Size(800, 1024), 1.0),
    (const Size(640, 360), 1.0),
    (const Size(360, 800), 2.0),
  ]) {
    testWidgets('All screens fit ${config.$1} with text scale ${config.$2}', (
      tester,
    ) async {
      await start(tester, size: config.$1, scale: config.$2);
      expect(tester.takeException(), isNull);
      await tap(tester, 'nav-products');
      expect(tester.takeException(), isNull);
      await tap(tester, 'product-headphones');
      expect(tester.takeException(), isNull);
      await tap(tester, 'add-to-cart');
      await tap(tester, 'detail-cart');
      await tester.drag(
        find.byKey(const ValueKey('cart-scroll')),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
