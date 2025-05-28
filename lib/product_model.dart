// lib/models/product_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String image;
  final String name;
  final String description;
  final double price;
  final bool available;
  final int stock;
  final List<String> sizes;

  Product({
    required this.id,
    required this.image,
    required this.name,
    required this.description,
    required this.price,
    required this.available,
    required this.stock,
    required this.sizes,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Product(
      id: doc.id,
      image: data['imagen_url'] ?? '',
      name: data['nombre'] ?? '',
      description: data['description'] ?? '',
      price: (data['precio_venta'] ?? 0).toDouble(),
      available: data['disponible'] ?? false,
      stock: data['stock'] ?? 0,
      sizes: List<String>.from(data['sizes'] ?? ['4', '5', '6', '7', '8', '9']),
    );
  }
}
