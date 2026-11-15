import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'data/catalog_repository.dart';
import 'models/product.dart';
import 'screens/catalog_shell.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MiniCatalogApp());
}

class MiniCatalogApp extends StatelessWidget {
  const MiniCatalogApp({super.key, this.loadProducts = loadCatalog});
  final Future<List<Product>> Function() loadProducts;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Mini Katalog',
    debugShowCheckedModeBanner: false,
    locale: const Locale('tr', 'TR'),
    supportedLocales: const [Locale('tr', 'TR')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: buildAppTheme(),
    home: CatalogShell(loadProducts: loadProducts),
  );
}
