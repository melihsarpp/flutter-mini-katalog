import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../data/catalog_repository.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../widgets/catalog_widgets.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.onAdd,
  });
  final Product product;
  final bool Function(Product, int) onAdd;
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  bool _added = false;
  void _add() {
    final added = widget.onAdd(widget.product, _quantity);
    if (added) setState(() => _added = true);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added
              ? '$_quantity adet ürün sepetine eklendi.'
              : 'Bu üründen en fazla ${widget.product.stock} adet ekleyebilirsin.',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const ValueKey('detail-back'),
          tooltip: 'Geri',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        centerTitle: true,
        title: const Text(
          'Ürüne yakından bak',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            key: const ValueKey('detail-cart'),
            tooltip: 'Sepete git',
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.shopping_bag_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            key: const ValueKey('detail-scroll'),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              SizedBox(
                height: math.min(MediaQuery.sizeOf(context).width * .86, 380),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: ProductImage(product: p),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      p.category.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.forest,
                        letterSpacing: 1.7,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Icon(Icons.circle, size: 7, color: AppColors.forest),
                  const SizedBox(width: 6),
                  Text(
                    p.stock > 0 ? 'Stokta' : 'Tükendi',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                p.name,
                key: const ValueKey('detail-name'),
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 10),
              Text(
                formatPrice(p.priceKurus),
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: AppColors.forest,
                ),
              ),
              const SizedBox(height: 22),
              const Divider(),
              const SizedBox(height: 18),
              Text(
                'Neden seveceksin?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Text(
                p.description,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.65,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: p.features
                    .map(
                      (feature) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBEEE5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          feature,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.forest,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 20,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Adet seç',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  QuantityControl(
                    quantity: _quantity,
                    label: 'Ürün',
                    onDecrease: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                    onIncrease: _quantity < p.stock
                        ? () => setState(() => _quantity++)
                        : null,
                  ),
                ],
              ),
              if (_added)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: TextButton.icon(
                    key: const ValueKey('added-view-cart'),
                    onPressed: () => Navigator.pop(context, true),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Sepete eklendi · Sepeti gör'),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.line)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final price = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'SEÇİMİNİN TOPLAMI',
                    style: TextStyle(
                      fontSize: 9,
                      letterSpacing: 1.2,
                      color: AppColors.muted,
                    ),
                  ),
                  Text(
                    formatPrice(p.priceKurus * _quantity),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: AppColors.forest,
                    ),
                  ),
                ],
              );
              final button = FilledButton.icon(
                key: const ValueKey('add-to-cart'),
                onPressed: p.stock > 0 ? _add : null,
                icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
                label: Text(p.stock > 0 ? 'Sepete ekle' : 'Tükendi'),
              );
              if (constraints.maxWidth < 330 ||
                  MediaQuery.textScalerOf(context).scale(14) > 19) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [price, const SizedBox(height: 10), button],
                );
              }
              return Row(
                children: [
                  Expanded(child: price),
                  const SizedBox(width: 12),
                  button,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
