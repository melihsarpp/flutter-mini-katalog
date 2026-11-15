import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_mini_katalog/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Android catalog, filters, detail and cart with real screenshots',
    (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();

      Future<void> capture(String name) async {
        await tester.pumpAndSettle();
        await binding.takeScreenshot(name);
      }

      Future<void> tap(String key) async {
        if (find.byKey(ValueKey(key)).hitTestable().evaluate().isEmpty) {
          await tester.ensureVisible(find.byKey(ValueKey(key)));
        }
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(ValueKey(key)));
        await tester.pumpAndSettle();
      }

      String total() =>
          tester.widget<Text>(find.byKey(const ValueKey('cart-total'))).data!;

      expect(find.text('mini.'), findsOneWidget);
      await capture('01-ana-sayfa');
      await tap('nav-products');
      await capture('02-urunler-izgara');
      await tap('view-list');
      await capture('03-urunler-liste');
      await tap('nav-products');
      await tester.enterText(
        find.byKey(const ValueKey('catalog-search')),
        'canta',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      expect(find.text('Kanvas Omuz Çantası'), findsOneWidget);
      expect(find.text('Studio Kulaklık'), findsNothing);
      await capture('04-arama');
      await tap('clear-search');
      await tap('category-Teknoloji');
      expect(find.text('3 ürün keşfetmeni bekliyor'), findsOneWidget);
      await tap('view-grid');
      await capture('05-kategori');
      await tap('product-headphones');
      expect(find.byKey(const ValueKey('detail-name')), findsOneWidget);
      await capture('06-urun-detay');
      await tap('add-to-cart');
      await tap('add-to-cart');
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await tap('detail-cart');
      expect(total(), '4.999,80 ₺');
      await capture('07-sepet');
      await tester.tap(find.byTooltip('Studio Kulaklık adedini artır'));
      await tester.pumpAndSettle();
      expect(total(), '7.499,70 ₺');
      await tester.tap(find.byTooltip('Studio Kulaklık adedini azalt'));
      await tester.pumpAndSettle();
      expect(total(), '4.999,80 ₺');
      await tap('remove-headphones');
      expect(find.text('Sepetin henüz boş'), findsOneWidget);
      await capture('08-bos-sepet');
      await tap('nav-home');
      expect(tester.takeException(), isNull);
    },
  );
}
