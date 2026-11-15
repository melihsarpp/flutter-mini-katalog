import 'package:material_ui/material_ui.dart';

import '../data/catalog_repository.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../widgets/catalog_widgets.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';

const categoryIcons = <String, IconData>{
  'Tümü': Icons.grid_view_rounded,
  'Teknoloji': Icons.headphones_rounded,
  'Ev & Yaşam': Icons.chair_outlined,
  'Aksesuar': Icons.watch_outlined,
  'Spor': Icons.sports_basketball_outlined,
};

class CatalogShell extends StatefulWidget {
  const CatalogShell({super.key, required this.loadProducts});
  final Future<List<Product>> Function() loadProducts;
  @override
  State<CatalogShell> createState() => _CatalogShellState();
}

class _CatalogShellState extends State<CatalogShell> {
  final _search = TextEditingController();
  final _catalogScroll = ScrollController();
  final Map<String, CartItem> _cart = {};
  List<Product> _products = [];
  bool _loading = true, _failed = false, _listView = false;
  int _page = 0;
  String _category = 'Tümü';
  int get _cartCount =>
      _cart.values.fold(0, (sum, item) => sum + item.quantity);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    _catalogScroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final products = await widget.loadProducts();
      if (mounted) {
        setState(() {
          _products = products;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _failed = true;
        });
      }
    }
  }

  void _browse([String category = 'Tümü']) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_catalogScroll.hasClients) _catalogScroll.jumpTo(0);
    setState(() {
      _page = 1;
      _category = category;
      _search.clear();
    });
  }

  bool _add(Product product, int quantity) {
    final next = (_cart[product.id]?.quantity ?? 0) + quantity;
    if (quantity < 1 || next > product.stock) return false;
    setState(
      () => _cart[product.id] = CartItem(product: product, quantity: next),
    );
    return true;
  }

  void _changeQuantity(Product product, int quantity) {
    if (quantity > product.stock) return;
    setState(() {
      if (quantity <= 0) {
        _cart.remove(product.id);
      } else {
        _cart[product.id] = CartItem(product: product, quantity: quantity);
      }
    });
  }

  Future<void> _openProduct(Product product) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final showCart = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: product, onAdd: _add),
      ),
    );
    if (mounted && showCart == true) setState(() => _page = 2);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: _page == 2
              ? CartScreen(
                  items: _cart.values.toList(),
                  onQuantityChanged: _changeQuantity,
                  onBrowse: _browse,
                  onOpen: _openProduct,
                )
              : _loading
              ? const Center(child: CircularProgressIndicator())
              : _failed
              ? SingleChildScrollView(
                  child: EmptyState(
                    icon: Icons.cloud_off_rounded,
                    title: 'Katalog yüklenemedi',
                    message: 'Ürünleri yeniden yüklemeyi deneyebilirsin.',
                    action: 'Yeniden dene',
                    onAction: _load,
                  ),
                )
              : _catalog(),
        ),
      ),
    ),
    bottomNavigationBar: DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: NavigationBar(
        height: 72,
        selectedIndex: _page,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.lime,
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        onDestinationSelected: (index) {
          FocusManager.instance.primaryFocus?.unfocus();
          if (_catalogScroll.hasClients) _catalogScroll.jumpTo(0);
          setState(() {
            _page = index;
            if (index == 0) {
              _search.clear();
              _category = 'Tümü';
            }
          });
        },
        destinations: [
          const NavigationDestination(
            key: ValueKey('nav-home'),
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Keşfet',
          ),
          const NavigationDestination(
            key: ValueKey('nav-products'),
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Ürünler',
          ),
          NavigationDestination(
            key: const ValueKey('nav-cart'),
            icon: Badge(
              isLabelVisible: _cartCount > 0,
              label: Text('$_cartCount'),
              backgroundColor: AppColors.forest,
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            label: 'Sepet',
          ),
        ],
      ),
    ),
  );

  Widget _catalog() {
    final home = _page == 0;
    final filtered = filterProducts(_products, _search.text, _category);
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
        final width = constraints.maxWidth - 40;
        final columns = width < 310 || scale > 1.35
            ? 1
            : width > 740
            ? 4
            : width > 540
            ? 3
            : 2;
        final showList = !home && (_listView || scale > 1.35);
        final visible = home ? filtered.take(4).toList() : filtered;
        return ListView(
          key: const ValueKey('catalog-scroll'),
          controller: _catalogScroll,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (home) ...[
                        const Text(
                          'AZ, ÖZ, SANA GÖRE.',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 2.2,
                            fontWeight: FontWeight.w700,
                            color: AppColors.forest,
                          ),
                        ),
                        const Text(
                          'mini.',
                          style: TextStyle(
                            fontSize: 37,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -2,
                            height: 1.2,
                            color: AppColors.forest,
                          ),
                        ),
                      ] else ...[
                        const Text(
                          'MİNİ KATALOG',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 2,
                            color: AppColors.forest,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Koleksiyonu keşfet',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  key: const ValueKey('header-cart'),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.forest,
                  ),
                  onPressed: () => setState(() => _page = 2),
                  tooltip: 'Sepeti aç',
                  icon: Badge(
                    isLabelVisible: _cartCount > 0,
                    label: Text('$_cartCount'),
                    backgroundColor: AppColors.forest,
                    child: const Icon(Icons.shopping_bag_outlined),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              key: const ValueKey('catalog-search'),
              controller: _search,
              textInputAction: TextInputAction.search,
              onChanged: (_) => setState(() => _page = 1),
              onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
              decoration: InputDecoration(
                hintText: 'Sana iyi gelecek bir şey ara…',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.muted,
                ),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        key: const ValueKey('clear-search'),
                        tooltip: 'Aramayı temizle',
                        onPressed: () => setState(_search.clear),
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
            const SizedBox(height: 22),
            if (home) ...[
              _HeroBanner(onTap: () => _browse('Ev & Yaşam')),
              const SizedBox(height: 26),
              Text(
                'Senin dünyan',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categoryIcons.entries
                      .where((e) => e.key != 'Tümü')
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(right: 22),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _browse(e.key),
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Column(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: e.key == 'Ev & Yaşam'
                                          ? AppColors.lime
                                          : const Color(0xFFEBEEE5),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Icon(
                                      e.value,
                                      color: AppColors.forest,
                                      size: 25,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    e.key,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 26),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Seveceğini düşündük',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  TextButton(
                    key: const ValueKey('see-all'),
                    onPressed: _browse,
                    child: const Text('Tümünü gör'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ] else ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categoryIcons.entries
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            key: ValueKey('category-${e.key}'),
                            label: Text(e.key),
                            avatar: Icon(e.value, size: 17),
                            showCheckmark: false,
                            selected: _category == e.key,
                            selectedColor: AppColors.lime,
                            side: BorderSide(
                              color: _category == e.key
                                  ? AppColors.forest
                                  : AppColors.line,
                            ),
                            onSelected: (_) =>
                                setState(() => _category = e.key),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${filtered.length} ürün keşfetmeni bekliyor',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  IconButton(
                    key: const ValueKey('view-grid'),
                    tooltip: 'Izgara görünümü',
                    isSelected: !_listView,
                    onPressed: () => setState(() => _listView = false),
                    color: !_listView ? AppColors.forest : AppColors.muted,
                    icon: const Icon(Icons.grid_view_rounded, size: 21),
                  ),
                  IconButton(
                    key: const ValueKey('view-list'),
                    tooltip: 'Liste görünümü',
                    isSelected: _listView,
                    onPressed: () => setState(() => _listView = true),
                    color: _listView ? AppColors.forest : AppColors.muted,
                    icon: const Icon(Icons.view_agenda_outlined, size: 21),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (visible.isEmpty)
              EmptyState(
                icon: Icons.search_off_rounded,
                title: 'Aradığını bulamadık',
                message: 'Başka bir kelime veya kategori deneyebilirsin.',
                action: 'Filtreleri temizle',
                onAction: _browse,
              )
            else if (showList)
              ListView.builder(
                key: const ValueKey('product-list'),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: visible.length,
                itemBuilder: (_, index) => ProductListTile(
                  key: ValueKey('product-${visible[index].id}'),
                  product: visible[index],
                  onTap: () => _openProduct(visible[index]),
                ),
              )
            else
              GridView.builder(
                key: const ValueKey('product-grid'),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: visible.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 16,
                  mainAxisExtent: 268 + (scale - 1) * 110,
                ),
                itemBuilder: (_, index) => ProductCard(
                  key: ValueKey('product-${visible[index].id}'),
                  product: visible[index],
                  onTap: () => _openProduct(visible[index]),
                ),
              ),
            if (home) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBEEE5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.eco_outlined, color: AppColors.forest),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Küçük seçimler, güzel bir yaşam.\nKendi favorilerini keşfet.',
                        style: TextStyle(color: AppColors.forest, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/hero.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.centerRight,
            excludeFromSemantics: true,
          ),
        ),
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xF0204D3C),
                  Color(0xA6204D3C),
                  Color(0x18204D3C),
                ],
                stops: [0, .48, 1],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'YAŞAM ALANINA İLHAM',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.7,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lime,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'İyi tasarım.\nGüzel yaşam.',
                style: TextStyle(
                  fontSize: 30,
                  height: 1.12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.7,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                key: const ValueKey('hero-cta'),
                onPressed: onTap,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.lime,
                  foregroundColor: AppColors.forest,
                  minimumSize: const Size(0, 42),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                label: const Text('Koleksiyonu keşfet'),
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                iconAlignment: IconAlignment.end,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
