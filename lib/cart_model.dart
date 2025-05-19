// cart_model.dart

class CartModel {
  final String image;
  final String name;
  final double price;
  final String size;

  CartModel({
    required this.image,
    required this.name,
    required this.price,
    required this.size,
  });
}

class CartItem {
  final String productName;
  final int quantity;
  final String imagePath;

  CartItem({
    required this.productName,
    required this.quantity,
    required this.imagePath,
  });
}
