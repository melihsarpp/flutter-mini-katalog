import 'package:material_ui/material_ui.dart';

import '../data/catalog_repository.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../widgets/catalog_widgets.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({
    super.key,
    required this.items,
    required this.onQuantityChanged,
    required this.onBrowse,
    required this.onOpen,
  });
  final List<CartItem> items;
  final void Function(Product, int) onQuantityChanged;
  final VoidCallback onBrowse;
  final void Function(Product) onOpen;

  @override
  Widget build(BuildContext context) {
    final count = items.fold(0, (sum, item) => sum + item.quantity);
    final total = items.fold(0, (sum, item) => sum + item.totalKurus);
    return ListView(
      key: const ValueKey('cart-scroll'),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        const Text(
          'GÜZEL SEÇİMLER',
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 2,
            color: AppColors.forest,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text('Sepetim', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 7),
        Text(
          '$count ürün, sana biraz daha yakın.',
          style: const TextStyle(color: AppColors.muted),
        ),
        const SizedBox(height: 26),
        if (items.isEmpty) const SizedBox(height: 40),
        if (items.isEmpty)
          EmptyState(
            icon: Icons.shopping_bag_outlined,
            title: 'Sepetin henüz boş',
            message: 'Güzel bir şeyle başlayalım.\nYeni favorin koleksiyonda seni bekliyor.',
            action: 'Ürünleri keşfet',
            onAction: onBrowse,
          )
        else ...[
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
                key: ValueKey('cart-item-${item.product.id}'),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => onOpen(item.product),
                          child: SizedBox(
                            width: 86,
                            height: 100,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(13),
                              child: ProductImage(product: item.product),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.category,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.product.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                formatPrice(item.product.priceKurus),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.forest,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          key: ValueKey('remove-${item.product.id}'),
                          tooltip: '${item.product.name} ürününü kaldır',
                          onPressed: () => onQuantityChanged(item.product, 0),
                          icon: const Icon(Icons.close_rounded, size: 19),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 18,
                      runSpacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        QuantityControl(
                          quantity: item.quantity,
                          label: item.product.name,
                          onDecrease: () => onQuantityChanged(
                            item.product,
                            item.quantity - 1,
                          ),
                          onIncrease: item.quantity < item.product.stock
                              ? () => onQuantityChanged(
                                  item.product,
                                  item.quantity + 1,
                                )
                              : null,
                        ),
                        Text(
                          formatPrice(item.totalKurus),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.forest,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Seçimlerinin özeti',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Ürün adedi',
                        style: TextStyle(color: Color(0xFFCED8CB)),
                      ),
                    ),
                    Text(
                      '$count adet',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(color: Color(0xFF52715F)),
                ),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 20,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'Toplam',
                      style: TextStyle(color: Colors.white, fontSize: 17),
                    ),
                    Text(
                      formatPrice(total),
                      key: const ValueKey('cart-total'),
                      style: const TextStyle(
                        color: AppColors.lime,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Bu bir sepet simülasyonudur. Ödeme alınmaz; kargo ücreti hesaplanmaz.',
                  style: TextStyle(
                    color: Color(0xFFCED8CB),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onBrowse,
            label: const Text('Keşfetmeye devam et'),
            icon: const Icon(Icons.arrow_forward_rounded, size: 19),
            iconAlignment: IconAlignment.end,
          ),
        ],
      ],
    );
  }
}
