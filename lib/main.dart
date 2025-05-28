// main.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'cart_model.dart';
import 'user_data.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';

FirebaseFirestore db = FirebaseFirestore.instance;
// --------------------- Variables Globales ---------------------
List<Map<String, dynamic>> cartItems = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MrSneakerApp());
}

class MrSneakerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MR. SNEAKER APP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Arial'),
      home: SplashScreen(),
    );
  }
}

// ------------------------- SPLASH SCREEN -------------------------

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(251, 255, 235, 60),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color.fromARGB(251, 255, 235, 60),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Image.asset('assets/images/logo.png'),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'MR. SNEAKER APP',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text('INICIAR SESION'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RegisterScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text('REGISTRATE AHORA'),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------ LOGIN Y REGISTRO ------------------------

class LoginScreen extends StatelessWidget {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'BIENVENIDO A MR. SNEAKERS APP',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              TextField(
                controller: userController,
                decoration: InputDecoration(
                  hintText: 'Usuario',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Contraseña',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
                ),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ), // Este paréntesis estaba faltando
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => HomeScreen()),
                    );
                  },
                  child: Text('Ingresar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController motherLastNameController =
      TextEditingController();
  final TextEditingController userController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool acceptTerms = false;

  Future<void> _registerUser(BuildContext context) async {
    try {
      // Validar campos no vacíos
      if (nameController.text.isEmpty ||
          lastNameController.text.isEmpty ||
          motherLastNameController.text.isEmpty ||
          userController.text.isEmpty ||
          emailController.text.isEmpty ||
          passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, complete todos los campos')),
        );
        return;
      }

      if (!acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debe aceptar los términos y condiciones'),
          ),
        );
        return;
      }

      // Guardar en Firestore
      await _firestore.collection('users').doc(emailController.text).set({
        'nombres': nameController.text,
        'apellido_paterno': lastNameController.text,
        'apellido_materno': motherLastNameController.text,
        'usuario': userController.text,
        'email': emailController.text,
        'contraseña': passwordController.text,
        'fecha_registro': FieldValue.serverTimestamp(),
        'acepto_terminos': acceptTerms,
      });

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registro exitoso!')));

      // Redirigir a login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'CREA TU CUENTA',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 30),
              _buildTextField('Nombre(s)', nameController),
              SizedBox(height: 15),
              _buildTextField('Apellido paterno', lastNameController),
              SizedBox(height: 15),
              _buildTextField('Apellido materno', motherLastNameController),
              SizedBox(height: 15),
              _buildTextField('Usuario', userController),
              SizedBox(height: 15),
              _buildTextField('Correo electrónico', emailController),
              SizedBox(height: 15),
              _buildTextField(
                'Contraseña',
                passwordController,
                isPassword: true,
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: acceptTerms,
                    onChanged: (value) {
                      setState(() {
                        acceptTerms = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Aquí puedes navegar a una pantalla con los términos y condiciones
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: Text('Términos y Condiciones'),
                                content: Text(
                                  'Términos y condiciones de la app',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Aceptar'),
                                  ),
                                ],
                              ),
                        );
                      },
                      child: Text(
                        'Acepto los términos y condiciones',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.black,
                  ),
                  onPressed: () => _registerUser(context),
                  child: Text(
                    'Crear cuenta',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hintText,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // <-- Coma aquí
        ), // <-- Paréntesis que cierra OutlineInputBorder
        contentPadding: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ), // <-- Coma aquí
      ), // <-- Paréntesis que cierra InputDecoration
    );
  }
}

// --------------------------- HOME ---------------------------
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  final TextEditingController searchController = TextEditingController();
  List<CartModel> cartItems = [];
  String? deliveryAddress;
  List<CartModel> lastOrderItems = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  void onRemoveFromCart(int index) {
    if (index >= 0 && index < cartItems.length) {
      setState(() {
        cartItems.removeAt(index);
      });
    }
  }

  Future<void> _fetchProducts() async {
    try {
      final querySnapshot = await _firestore.collection('productos').get();

      setState(() {
        products =
            querySnapshot.docs.map((doc) {
              final data = doc.data();
              // Extract the filename from the path
              String imagePath = data['imagen_url'] ?? '';
              // Convert local asset path to actual asset path or use Firebase Storage URL
              String imageUrl = _getProperImageUrl(imagePath);

              return {
                'id': doc.id,
                'image': imageUrl,
                'name': data['nombre'] ?? '',
                'price': (data['precio_venta'] ?? 0).toDouble(),
                'description': data['description'] ?? '',
                'available': data['disponible'] ?? false,
                'stock': data['stock'] ?? 0,
                'sizes': ['4', '5', '6', '7', '8', '9'],
              };
            }).toList();
        filteredProducts = List.from(products);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar productos: ${e.toString()}')),
      );
    }
  }

  // Function to convert local asset paths to proper URLs
  String _getProperImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      // It's already a URL
      return imagePath;
    } else if (imagePath.startsWith('assets/')) {
      // Option 1: If using local assets, we need to use AssetImage instead
      // For this example, we'll return a placeholder and modify the image widget later
      return imagePath;
    } else {
      // If it's a relative path in Firebase Storage
      // You should use your Firebase Storage URL pattern
      return 'https://firebasestorage.googleapis.com/v0/b/your-project-id.appspot.com/o/${Uri.encodeComponent(imagePath)}?alt=media';
    }
  }

  // Function to check if path is a local asset
  bool _isAssetPath(String path) {
    return path.startsWith('assets/');
  }

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void searchProducts(String query) {
    setState(() {
      filteredProducts =
          products
              .where(
                (product) =>
                    product['name'].toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    });
  }

  void onAddToCart(
    String image,
    String name,
    double price,
    String size, {
    String? description,
    bool? available,
    int? stock,
    List<String>? sizes,
  }) {
    setState(() {
      cartItems.add(
        CartModel(
          image: image,
          name: name,
          price: price,
          size: size,
          description: description,
          available: available,
          stock: stock,
          sizes: sizes,
        ),
      );
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Producto agregado al carrito')));
  }

  void clearCartAfterPayment(String address) {
    setState(() {
      lastOrderItems = List.from(cartItems);
      cartItems.clear();
      deliveryAddress = address;
      selectedIndex = 2;
    });
  }

  Widget _buildProductGrid() {
    if (filteredProducts.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.7,
      children:
          filteredProducts.map((product) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => ProductDetailScreen(
                          imagePath: product['image'],
                          productName: product['name'],
                          price: product['price'],
                          description: product['description'],
                          available: product['available'],
                          stock: product['stock'],
                          sizes: List<String>.from(product['sizes']),
                          onAddToCart:
                              (selectedSize) => onAddToCart(
                                product['image'],
                                product['name'],
                                product['price'],
                                selectedSize,
                                description: product['description'],
                                available: product['available'],
                                stock: product['stock'],
                                sizes: List<String>.from(product['sizes']),
                              ),
                        ),
                  ),
                );
              },
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child:
                            _isAssetPath(product['image'])
                                ? Image.asset(
                                  product['image'],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                )
                                : CachedNetworkImage(
                                  imageUrl: product['image'],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  placeholder:
                                      (context, url) => Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                  errorWidget:
                                      (context, url, error) =>
                                          Icon(Icons.error),
                                ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            '\$${product['price'].toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.inventory,
                                size: 14,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Stock: ${product['stock']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          if (!product['available'])
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                'Agotado',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildBody() {
    switch (selectedIndex) {
      case 0:
        return _buildProductGrid();
      case 1:
        return CartScreen(
          cartItems: cartItems,
          onConfirm: clearCartAfterPayment,
          onRemoveItem: onRemoveFromCart, // Add this line
          onAddToCart:
              (image, name, price, size) =>
                  onAddToCart(image, name, price, size), // Add this line
        );
      case 2:
        return deliveryAddress != null
            ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pedido enviado a:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(deliveryAddress ?? ''),
                          SizedBox(height: 16),
                          Text(
                            'Productos comprados:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          ...lastOrderItems.map(
                            (item) => Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child:
                                        _isAssetPath(item.image)
                                            ? Image.asset(
                                              item.image,
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                            )
                                            : CachedNetworkImage(
                                              imageUrl: item.image,
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                            ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text('Talla: ${item.size}'),
                                        Text(
                                          '\$${item.price.toStringAsFixed(2)}',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
            : Center(child: Text('No hay pedidos recientes'));
      case 3:
        return ProfileScreen();
      default:
        return Center(child: Text('Sección no implementada'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[600],
        title:
            selectedIndex == 0
                ? Row(
                  children: [
                    Image.asset('assets/images/logo.png', height: 40),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: searchProducts,
                        decoration: InputDecoration(
                          hintText: 'Buscar productos',
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
                : Text('MR. SNEAKER APP'),
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.yellow[600],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey[800],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Carrito',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Pedidos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

// ---------------------- PANTALLA DE SELECCIÓN DE PAGO ----------------------

class PaymentMethodScreen extends StatefulWidget {
  @override
  _PaymentMethodScreenState createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String? selectedCardType = 'Visa'; // Método de pago seleccionado
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Método de pago'),
        backgroundColor: Colors.yellow[600],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Selector de tarjeta (Visa o MasterCard)
            DropdownButton<String>(
              value: selectedCardType,
              onChanged: (String? newValue) {
                setState(() {
                  selectedCardType = newValue;
                });
              },
              items:
                  ['Visa', 'MasterCard']
                      .map(
                        (card) => DropdownMenuItem<String>(
                          value: card,
                          child: Text(card),
                        ),
                      )
                      .toList(),
              isExpanded: true,
            ),
            SizedBox(height: 20),
            // Campos para ingresar los datos de la tarjeta
            TextField(
              controller: cardNumberController,
              decoration: InputDecoration(
                labelText: 'Número de tarjeta',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            TextField(
              controller: expiryDateController,
              decoration: InputDecoration(
                labelText: 'Fecha de vencimiento (MM/YY)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
            ),
            SizedBox(height: 10),
            TextField(
              controller: cvvController,
              decoration: InputDecoration(
                labelText: 'CVV',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Simula la aceptación del pago
                if (cardNumberController.text.isNotEmpty &&
                    expiryDateController.text.isNotEmpty &&
                    cvvController.text.isNotEmpty) {
                  // Mostrar mensaje de confirmación
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Pago aceptado'),
                        content: Text(
                          '¡Gracias! Tu pago con tarjeta ${selectedCardType} ha sido aceptado. Procediendo con la compra.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, selectedCardType);
                              Navigator.pop(
                                context,
                              ); // Volver a la pantalla del carrito
                              // Notificación de pedido recibido
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Notificación'),
                                    content: Text(
                                      '¡Tu pedido ha sido aceptado! El tiempo estimado de entrega será notificado en breve.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text('Aceptar'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text('Aceptar'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Aceptar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------- DETALLE DE PRODUCTO ----------------------

class ProductDetailScreen extends StatefulWidget {
  final String imagePath;
  final String productName;
  final double price;
  final String description;
  final bool available;
  final int stock;
  final List<String> sizes;
  final Function(String) onAddToCart;

  const ProductDetailScreen({
    Key? key,
    required this.imagePath,
    required this.productName,
    required this.price,
    required this.description,
    required this.available,
    required this.stock,
    required this.sizes,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? _selectedSize; // Almacena la talla seleccionada

  // Function to check if path is a local asset
  bool _isAssetPath(String path) {
    return path.startsWith('assets/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productName),
        backgroundColor: Colors.yellow[600],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section with proper handling
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child:
                    _isAssetPath(widget.imagePath)
                        ? Image.asset(
                          widget.imagePath,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Imagen no disponible',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                        : CachedNetworkImage(
                          imageUrl: widget.imagePath,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder:
                              (context, url) => Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                color: Colors.grey[200],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error,
                                      size: 50,
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Error al cargar imagen',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        ),
              ),
            ),
            SizedBox(height: 16),

            // Product name
            Text(
              widget.productName,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            // Price
            Text(
              '\$${widget.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 16),

            // Availability status
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.available ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.available ? Icons.check_circle : Icons.cancel,
                    color:
                        widget.available ? Colors.green[700] : Colors.red[700],
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    widget.available ? 'Disponible' : 'Agotado',
                    style: TextStyle(
                      color:
                          widget.available
                              ? Colors.green[700]
                              : Colors.red[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Stock information
            Row(
              children: [
                Icon(Icons.inventory, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  'Stock disponible: ${widget.stock} unidades',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Description
            Text(
              'Descripción:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              widget.description,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 24),

            // Available sizes
            Text(
              'Tallas disponibles:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  widget.sizes.map((size) {
                    return ChoiceChip(
                      label: Text(
                        size,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      selected: _selectedSize == size,
                      selectedColor: Colors.yellow[600],
                      backgroundColor: Colors.grey[200],
                      onSelected:
                          widget.available && widget.stock > 0
                              ? (_) {
                                setState(() {
                                  _selectedSize = size;
                                });
                              }
                              : null,
                    );
                  }).toList(),
            ),
            SizedBox(height: 32),

            // Add to cart button
            if (widget.available && widget.stock > 0)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      _selectedSize == null
                          ? null
                          : () {
                            widget.onAddToCart(_selectedSize!);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Agregado al carrito - Talla: $_selectedSize',
                                ),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                            Navigator.pop(context);
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _selectedSize == null
                            ? Colors.grey[400]
                            : Colors.yellow[600],
                    foregroundColor: Colors.black,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined),
                      SizedBox(width: 8),
                      Text(
                        _selectedSize == null
                            ? 'Selecciona una talla'
                            : 'Agregar al carrito (Talla $_selectedSize)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Producto no disponible',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ------------------------- CARRITO -------------------------
class CartModel {
  final String image;
  final String name;
  final String size;
  final double price;
  final String? description; // Optional field for product details
  final bool? available; // Optional field for product availability
  final int? stock; // Optional field for product stock
  final List<String>? sizes; // Optional field for available sizes

  CartModel({
    required this.image,
    required this.name,
    required this.size,
    required this.price,
    this.description,
    this.available,
    this.stock,
    this.sizes,
  });

  get quantity => null;
}

class CartScreen extends StatefulWidget {
  final List<CartModel> cartItems;
  final Function(String address) onConfirm;
  final Function(int index)? onRemoveItem; // Callback for removing items
  final Function(String image, String name, double price, String size)?
  onAddToCart; // Callback for adding more items

  const CartScreen({
    Key? key,
    required this.cartItems,
    required this.onConfirm,
    this.onRemoveItem,
    this.onAddToCart,
  }) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Function to check if path is a local asset
  bool _isAssetPath(String path) {
    return path.startsWith('assets/');
  }

  // Function to build the appropriate image widget
  Widget _buildImageWidget(String imagePath, {double? width, double? height}) {
    if (_isAssetPath(imagePath)) {
      return Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: Icon(Icons.error, color: Colors.grey),
          );
        },
      );
    } else {
      return CachedNetworkImage(
        imageUrl: imagePath,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder:
            (context, url) => Container(
              width: width,
              height: height,
              color: Colors.grey[200],
              child: Center(child: CircularProgressIndicator()),
            ),
        errorWidget:
            (context, url, error) => Container(
              width: width,
              height: height,
              color: Colors.grey[200],
              child: Icon(Icons.error, color: Colors.grey),
            ),
      );
    }
  }

  // Calculate total price
  double get totalPrice {
    return widget.cartItems.fold(0.0, (sum, item) => sum + item.price);
  }

  // Navigate to product detail
  void _navigateToProductDetail(CartModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ProductDetailScreen(
              imagePath: item.image,
              productName: item.name,
              price: item.price,
              description: item.description ?? 'Descripción no disponible',
              available: item.available ?? true,
              stock: item.stock ?? 10,
              sizes: item.sizes ?? ['4', '5', '6', '7', '8', '9'],
              onAddToCart: (selectedSize) {
                if (widget.onAddToCart != null) {
                  widget.onAddToCart!(
                    item.image,
                    item.name,
                    item.price,
                    selectedSize,
                  );
                }
              },
            ),
      ),
    );
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar producto'),
          content: Text(
            '¿Estás seguro de que quieres eliminar este producto del carrito?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _removeItem(index);
              },
              child: Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Remove item from cart
  void _removeItem(int index) {
    if (widget.onRemoveItem != null) {
      widget.onRemoveItem!(index);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Producto eliminado del carrito'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.cartItems.isEmpty
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'El carrito está vacío',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Añade algunos productos para continuar',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        )
        : Column(
          children: [
            // Cart Header with item count and total
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.yellow[600],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Carrito de compras',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.cartItems.length} producto(s)',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Total:', style: TextStyle(fontSize: 14)),
                      Text(
                        '\$${totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Cart Items List
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(8),
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final item = widget.cartItems[index];
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () => _navigateToProductDetail(item),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _buildImageWidget(
                                item.image,
                                width: 80,
                                height: 80,
                              ),
                            ),
                            SizedBox(width: 12),

                            // Product Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.straighten,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Talla: ${item.size}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '\$${item.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Delete Button
                            Column(
                              children: [
                                IconButton(
                                  onPressed:
                                      () => _showDeleteConfirmation(index),
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 24,
                                  ),
                                  tooltip: 'Eliminar producto',
                                ),
                                Icon(
                                  Icons.touch_app,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                Text(
                                  'Ver detalles',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom Section with Total and Checkout Button
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Price Summary
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal (${widget.cartItems.length} productos):',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '\$${totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Checkout Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => CheckoutScreen(
                                  cartItems: widget.cartItems,
                                  onConfirm: widget.onConfirm,
                                ),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.payment),
                          SizedBox(width: 8),
                          Text(
                            'Continuar con el pago',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
  }
}

//--------------------------CHECKOUT-------------------------
// para usar CartModel

class CheckoutScreen extends StatefulWidget {
  final List<CartModel> cartItems;
  final Function(String address) onConfirm;

  const CheckoutScreen({
    Key? key,
    required this.cartItems,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _paymentMethod;
  String? _selectedState;
  final List<String> _methods = ['Visa', 'MasterCard', 'PayPal'];
  bool _isLoading = false;

  // Estados de México
  final List<String> mexicanStates = [
    'Aguascalientes',
    'Baja California',
    'Baja California Sur',
    'Campeche',
    'Chiapas',
    'Chihuahua',
    'Ciudad de México',
    'Coahuila',
    'Colima',
    'Durango',
    'Estado de México',
    'Guanajuato',
    'Guerrero',
    'Hidalgo',
    'Jalisco',
    'Michoacán',
    'Morelos',
    'Nayarit',
    'Nuevo León',
    'Oaxaca',
    'Puebla',
    'Querétaro',
    'Quintana Roo',
    'San Luis Potosí',
    'Sinaloa',
    'Sonora',
    'Tabasco',
    'Tamaulipas',
    'Tlaxcala',
    'Veracruz',
    'Yucatán',
    'Zacatecas',
  ];

  Future<void> _confirmOrder() async {
    // Validación mejorada de campos
    if (!_validateFields()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos correctamente'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Actualizar stock de productos con validación de cantidad
      await _updateProductStock();

      // 2. Crear registro del pedido
      await _createOrder();

      // 3. Confirmar y regresar
      final address =
          '${_streetController.text} #${_numberController.text}, ${_cityController.text}, $_selectedState, CP ${_postalCodeController.text}';
      widget.onConfirm(address);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Pedido confirmado con éxito!'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al procesar el pedido: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error inesperado: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _validateFields() {
    return _streetController.text.isNotEmpty &&
        _numberController.text.isNotEmpty &&
        _cityController.text.isNotEmpty &&
        _selectedState != null &&
        _postalCodeController.text.isNotEmpty &&
        _paymentMethod != null &&
        _cardNumberController.text.replaceAll(' ', '').length == 16 &&
        _expiryDateController.text.length == 5 &&
        _cvvController.text.length == 3;
  }

  Future<void> _updateProductStock() async {
    final batch = _firestore.batch();

    for (final item in widget.cartItems) {
      try {
        // Buscar producto por nombre
        final query =
            await _firestore
                .collection('productos')
                .where('name', isEqualTo: item.name)
                .limit(1)
                .get();

        if (query.docs.isNotEmpty) {
          final productDoc = query.docs.first;
          final productRef = productDoc.reference;
          final currentStock = productDoc.data()['stock'] ?? 0;

          // Validar que hay suficiente stock
          final quantityToBuy = item.quantity ?? 1;
          if (currentStock < quantityToBuy) {
            throw Exception(
              'No hay suficiente stock para ${item.name}. Stock disponible: $currentStock',
            );
          }

          // Actualizar stock
          batch.update(productRef, {
            'stock': FieldValue.increment(-quantityToBuy),
            'last_updated': FieldValue.serverTimestamp(),
          });
        } else {
          print('Producto no encontrado: ${item.name}');
        }
      } catch (e) {
        print('Error al actualizar stock para ${item.name}: $e');
        rethrow;
      }
    }

    await batch.commit();
    print('Stock actualizado correctamente para todos los productos');
  }

  Future<void> _createOrder() async {
    final address =
        '${_streetController.text} #${_numberController.text}, ${_cityController.text}, $_selectedState, CP ${_postalCodeController.text}';

    final orderData = {
      // Información de entrega
      'street': _streetController.text,
      'street_number': _numberController.text,
      'city': _cityController.text,
      'state': _selectedState,
      'postal_code': _postalCodeController.text,
      'full_address': address,

      // Información de pago
      'payment_method': _paymentMethod,
      'card_last_digits': _cardNumberController.text
          .replaceAll(' ', '')
          .substring(12),
      'expiry_date': _expiryDateController.text,

      // Información del pedido
      'date': FieldValue.serverTimestamp(),
      'items':
          widget.cartItems
              .map(
                (item) => {
                  'image': item.image,
                  'name': item.name,
                  'price': item.price,
                  'size': item.size,
                  'quantity': item.quantity ?? 1,
                  'subtotal': item.price * (item.quantity ?? 1),
                },
              )
              .toList(),
      'total': widget.cartItems.fold(
        0.0,
        (sum, item) => sum + (item.price * (item.quantity ?? 1)),
      ),
      'status': 'pending',
      'order_id': _generateOrderId(),
    };

    await _firestore.collection('orders').add(orderData);
    print('Pedido creado exitosamente');
  }

  String _generateOrderId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final date = DateTime.now();
    return 'ORD-${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}-$timestamp';
  }

  @override
  void dispose() {
    _streetController.dispose();
    _numberController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos de envío y pago'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                const Text(
                  'Dirección de entrega',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),

                // Calle
                TextField(
                  controller: _streetController,
                  decoration: const InputDecoration(
                    labelText: 'Calle',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // Número
                TextField(
                  controller: _numberController,
                  decoration: const InputDecoration(
                    labelText: 'Número',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),

                // Estado (Dropdown)
                DropdownButtonFormField<String>(
                  value: _selectedState,
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      mexicanStates
                          .map(
                            (state) => DropdownMenuItem<String>(
                              value: state,
                              child: Text(state),
                            ),
                          )
                          .toList(),
                  onChanged: (value) => setState(() => _selectedState = value),
                ),
                const SizedBox(height: 12),

                // Ciudad
                TextField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'Ciudad',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // Código Postal (máximo 5 dígitos)
                TextField(
                  controller: _postalCodeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Código Postal',
                    border: OutlineInputBorder(),
                    hintText: '12345',
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Método de pago',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 12),

                // Método de pago
                DropdownButtonFormField<String>(
                  value: _paymentMethod,
                  items:
                      _methods
                          .map(
                            (method) => DropdownMenuItem(
                              value: method,
                              child: Text(method),
                            ),
                          )
                          .toList(),
                  onChanged: (value) => setState(() => _paymentMethod = value),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Selecciona método de pago',
                  ),
                ),
                const SizedBox(height: 16),

                if (_paymentMethod != null && _paymentMethod != 'PayPal') ...[
                  // Número de tarjeta (16 dígitos con formato)
                  TextField(
                    controller: _cardNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Número de tarjeta',
                      border: OutlineInputBorder(),
                      hintText: '1234 5678 9012 3456',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(16),
                      CardNumberFormatter(),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      // Fecha de vencimiento (MM/YY con formato automático)
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _expiryDateController,
                          decoration: const InputDecoration(
                            labelText: 'Fecha de vencimiento',
                            border: OutlineInputBorder(),
                            hintText: 'MM/YY',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                            ExpiryDateFormatter(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      // CVV (3 dígitos)
                      Expanded(
                        child: TextField(
                          controller: _cvvController,
                          decoration: const InputDecoration(
                            labelText: 'CVV',
                            border: OutlineInputBorder(),
                            hintText: '123',
                          ),
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 32),

                // Botón de confirmar
                ElevatedButton(
                  onPressed: _isLoading ? null : _confirmOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'CONFIRMAR PEDIDO',
                            style: TextStyle(fontSize: 16),
                          ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

// Formateador para número de tarjeta (agregar espacios cada 4 dígitos)
class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll(' ', '');
    StringBuffer buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

// Formateador para fecha de vencimiento (MM/YY)
class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll('/', '');
    StringBuffer buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

// Asegúrate de que tu CartModel tenga el campo quantity
// Si no lo tiene, agrégalo o modifica la lógica según tu estructura

// ------------------------- PERFIL -------------------------

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con foto de perfil
            _buildProfileHeader(),
            const SizedBox(height: 30),

            // Sección de información de cuenta
            _buildAccountSection(),
            const SizedBox(height: 25),

            // Sección de ayuda
            _buildHelpSection(),
            const SizedBox(height: 30),

            // Botón de cerrar sesión
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          // Foto de perfil circular
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
              border: Border.all(color: Colors.blue.shade100, width: 3),
              image: DecorationImage(
                image: NetworkImage(
                  'https://ui-avatars.com/api/?name=${UserData().username}&background=random',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 15),
          // Nombre de usuario
          Text(
            UserData().username,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          // Correo electrónico
          Text(
            UserData().email,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información de la cuenta',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoTile(
              Icons.person_outline,
              'Usuario',
              UserData().username,
            ),
            const Divider(height: 1),
            _buildInfoTile(Icons.email_outlined, 'Correo', UserData().email),
            const Divider(height: 1),
            _buildInfoTile(
              Icons.lock_outline,
              'Contraseña',
              '••••••••',
              isPassword: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ayuda y Soporte',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),
            _buildHelpItem(
              '¿Dónde está mi pedido?',
              Icons.local_shipping_outlined,
            ),
            const Divider(height: 1),
            _buildHelpItem('¿Cómo cancelar un pedido?', Icons.cancel_outlined),
            const Divider(height: 1),
            _buildHelpItem(
              '¿Cómo cambiar la contraseña?',
              Icons.lock_reset_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String title,
    String value, {
    bool isPassword = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: Text(
        isPassword ? '••••••••' : value,
        style: TextStyle(color: Colors.grey[600]),
      ),
      onTap: () {
        // Aquí podrías añadir funcionalidad para editar cada campo
      },
    );
  }

  Widget _buildHelpItem(String title, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        // Navegar a pantalla de ayuda específica
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.logout, size: 20),
        label: const Text('Cerrar sesión', style: TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[400],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        onPressed: () {
          _showLogoutConfirmation(context);
        },
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cerrar sesión'),
            content: const Text('¿Estás seguro que deseas cerrar tu sesión?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => SplashScreen()),
                    (route) => false,
                  );
                },
                child: const Text(
                  'Cerrar sesión',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
