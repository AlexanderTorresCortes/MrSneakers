// cart_model.dart

class CartModel {
  final String productId;
  final String image;
  final String name;
  final double price;
  final String size;
  final int? quantity; // Agregamos quantity como nullable

  CartModel({
    required this.productId,
    required this.image,
    required this.name,
    required this.price,
    required this.size,
    this.quantity, // quantity es opcional
  });

  // Método para obtener la cantidad a comprar con valor por defecto
  int get quantityToBuy => quantity ?? 1;
}

class CartItem {
  final String productName;
  final int? quantity; // Cambiamos a nullable para consistencia
  final String imagePath;

  CartItem({
    required this.productName,
    this.quantity, // quantity es opcional
    required this.imagePath,
  });

  // Método para obtener la cantidad a comprar con valor por defecto
  int get quantityToBuy => quantity ?? 1;
}
