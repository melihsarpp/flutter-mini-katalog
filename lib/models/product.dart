class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.priceKurus,
    required this.image,
    required this.description,
    required this.stock,
    required this.features,
    this.tag = '',
  });
  final String id, name, category, image, description, tag;
  // Integer kuruş avoids floating-point rounding errors in cart totals.
  final int priceKurus, stock;
  final List<String> features;

  factory Product.fromJson(Map<String, dynamic> json) {
    String readString(String key) {
      final value = json[key];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('Geçersiz ürün alanı: $key');
      }
      return value;
    }

    final price = json['priceKurus'];
    final stock = json['stock'];
    final features = json['features'];
    if (price is! int ||
        price <= 0 ||
        stock is! int ||
        stock < 0 ||
        features is! List ||
        features.any((value) => value is! String)) {
      throw const FormatException('Geçersiz fiyat, stok veya özellik bilgisi.');
    }
    final image = readString('image');
    if (!image.startsWith('assets/images/') || image.contains('..')) {
      throw const FormatException('Ürün görseli yerel bir asset olmalıdır.');
    }
    return Product(
      id: readString('id'),
      name: readString('name'),
      category: readString('category'),
      priceKurus: price,
      image: image,
      description: readString('description'),
      stock: stock,
      features: List<String>.unmodifiable(features.cast<String>()),
      tag: json['tag'] as String? ?? '',
    );
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'priceKurus': priceKurus,
    'image': image,
    'description': description,
    'stock': stock,
    'features': features,
    'tag': tag,
  };
}
