class CartModel {
  final String productId; // Nuevo campo para identificar el producto
  final String image;
  final String name;
  final String size;
  final double price;
  final int quantity; // Cambiado de nullable a requerido
  final String? description;
  final bool? available;
  final int? stock;
  final List<String>? sizes;

  CartModel({
    required this.productId, // Añadido
    required this.image,
    required this.name,
    required this.size,
    required this.price,
    this.quantity = 1, // Valor por defecto
    this.description,
    this.available,
    this.stock,
    this.sizes,
  });

  // Método para convertir a Map (para Firestore)
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'image': image,
      'name': name,
      'size': size,
      'price': price,
      'quantity': quantity,
      'description': description,
      'available': available,
      'stock': stock,
      'sizes': sizes,
    };
  }

  // Método para crear desde Map
  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      productId: map['productId'] ?? '',
      image: map['image'] ?? '',
      name: map['name'] ?? '',
      size: map['size'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      quantity: map['quantity']?.toInt() ?? 1,
      description: map['description'],
      available: map['available'],
      stock: map['stock']?.toInt(),
      sizes: map['sizes'] != null ? List<String>.from(map['sizes']) : null,
    );
  }
}
