// main.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'cart_model.dart';
import 'user_data.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// Modificación del LoginScreen para añadir autenticación con Google
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
  final TextEditingController emailController =
      TextEditingController(); // Cambiado de userController a emailController
  final TextEditingController passwordController = TextEditingController();

  // Instancias de Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Función para inicio de sesión con email y contraseña
  Future<void> _signInWithEmail(BuildContext context) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa tu correo y contraseña'),
        ),
      );
      return;
    }

    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Iniciar sesión con Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Obtener datos adicionales del usuario desde Firestore
      DocumentSnapshot userDoc =
          await _firestore
              .collection('users')
              .doc(userCredential.user?.uid)
              .get();

      // Cerrar indicador de carga
      Navigator.pop(context);

      if (userDoc.exists) {
        // Guardar datos localmente (opcional)
        UserData().username = userDoc['name'] ?? 'Usuario';
        UserData().email = emailController.text;
        UserData().password =
            '********'; // Por seguridad no almacenamos la contraseña real

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inicio de sesión exitoso')),
        );

        // Navegar a la pantalla de inicio
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Cerrar indicador de carga
      String errorMessage = 'Error al iniciar sesión';
      if (e.code == 'user-not-found') {
        errorMessage = 'Usuario no encontrado';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Contraseña incorrecta';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Correo electrónico inválido';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      Navigator.pop(context); // Cerrar indicador de carga
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  // Función para inicio de sesión con Google
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      // Iniciar el proceso de inicio de sesión con Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Si el usuario cancela, salir de la función
      if (googleUser == null) {
        Navigator.pop(context);
        return;
      }

      // Obtener detalles de autenticación
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Crear credencial para Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Iniciar sesión en Firebase con la credencial de Google
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      // Cerrar indicador de carga
      Navigator.pop(context);

      if (user != null) {
        // Guardar los datos del usuario
        UserData().username = user.displayName ?? 'Usuario';
        UserData().email = user.email ?? '';
        UserData().password = '********';

        // Actualizar/crear documento en Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': user.displayName,
          'email': user.email,
          'photoUrl': user.photoURL,
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inicio de sesión exitoso')),
        );

        // Navegar a la pantalla de inicio
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      }
    } catch (e) {
      // Cerrar indicador de carga si hay un error
      Navigator.pop(context);
      // Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 80),
          child: Column(
            children: [
              Icon(Icons.account_circle, size: 120, color: Colors.blue[300]),
              const SizedBox(height: 20),
              const Text(
                'BIENVENIDO A MR. SNEAKERS APP',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email),
                  hintText: 'Correo electrónico',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  hintText: 'Contraseña',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _signInWithEmail(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Ingresar'),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              const Text('O inicia sesión con', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Image.asset('assets/images/google.png', height: 24.0),
                label: const Text('Continuar con Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Colors.grey),
                ),
                onPressed: () => signInWithGoogle(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Instancias de Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Función para registro con email y contraseña
  Future<void> _registerWithEmail(BuildContext context) async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    if (!emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un correo electrónico válido')),
      );
      return;
    }

    if (passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La contraseña debe tener al menos 6 caracteres'),
        ),
      );
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // 1. Registrar usuario en Firebase Authentication
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );

      // 2. Guardar datos adicionales en Firestore
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'name': nameController.text,
        'email': emailController.text,
        'createdAt': FieldValue.serverTimestamp(),
        'provider': 'email',
      });

      // 3. Cerrar el diálogo de carga
      Navigator.pop(context);

      // 4. Mostrar mensaje de éxito y navegar
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registro exitoso!')));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(),
        ), // Reemplaza con tu pantalla de inicio
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      String errorMessage = 'Ocurrió un error';
      if (e.code == 'weak-password') {
        errorMessage = 'La contraseña es muy débil';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'El correo ya está registrado';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  // Función para registro con Google
  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // 1. Iniciar sesión con Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        Navigator.pop(context);
        return;
      }

      // 2. Obtener credenciales
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 3. Registrar en Firebase Auth
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      if (user != null) {
        // 4. Guardar datos en Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': user.displayName,
          'email': user.email,
          'photoUrl': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'provider': 'google',
        }, SetOptions(merge: true));

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro con Google exitoso!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(),
          ), // Reemplaza con tu pantalla de inicio
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error con Google: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              const SizedBox(height: 80),
              const Text(
                'Crea tu cuenta',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _registerWithEmail(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Registrarse'),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              const Text('O regístrate con', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Image.asset('assets/images/google.png', height: 24.0),
                label: const Text('Continuar con Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Colors.grey),
                ),
                onPressed: () => _signInWithGoogle(context),
              ),
            ],
          ),
        ),
      ),
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

  List<Map<String, dynamic>> shoes = [
    {
      'image': 'assets/images/converse.png',
      'name': 'Converse Run Star Motion',
      'price': 1999.00,
      'sizes': ['6', '7', '8', '9'],
      'color': 'Rosa',
    },
  ];

  List<Map<String, dynamic>> filteredShoes = [];

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void searchShoes(String query) {
    setState(() {
      filteredShoes =
          shoes
              .where(
                (shoe) =>
                    shoe['name'].toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    });
  }

  void onAddToCart(CartModel item) {
    setState(() {
      cartItems.add(item);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Producto agregado al carrito')));
  }

  void clearCartAfterPayment(String address) {
    setState(() {
      lastOrderItems = List.from(
        cartItems,
      ); // Guardar productos antes de limpiar
      cartItems.clear();
      deliveryAddress = address;
      selectedIndex = 2;
    });
  }

  Widget _buildBody() {
    switch (selectedIndex) {
      case 0:
        return GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(16),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children:
              (filteredShoes.isNotEmpty ? filteredShoes : shoes)
                  .map(
                    (shoe) => GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ProductDetailScreen(
                                  imagePath: shoe['image'],
                                  productName: shoe['name'],
                                  price: shoe['price'],
                                  sizes: List<String>.from(shoe['sizes']),
                                  color: shoe['color'],
                                  stock:
                                      10, // si no lo tienes definido, pon uno fijo por ahora
                                  onAddToCart: onAddToCart,
                                ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Image.asset(shoe['image']),
                      ),
                    ),
                  )
                  .toList(),
        );
      case 1:
        return CartScreen(
          cartItems: cartItems,
          onConfirm: clearCartAfterPayment,
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
                                    child: Image.asset(
                                      item.image,
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
            : Center(child: Text('Sin notificaciones'));

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
                        onChanged: searchShoes,
                        decoration: InputDecoration(
                          hintText: 'Buscar',
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
            label: 'Notificaciones',
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
  final List<String> sizes; // Lista de tallas disponibles
  final String color; // Color disponible
  final int stock;
  final Function(CartModel) onAddToCart;

  ProductDetailScreen({
    required this.imagePath,
    required this.productName,
    required this.price,
    required this.sizes,
    required this.color,
    required this.stock,
    required this.onAddToCart,
  });

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? selectedSize; // Variable para almacenar la talla seleccionada

  @override
  void initState() {
    super.initState();
    selectedSize =
        widget.sizes.isNotEmpty
            ? widget.sizes[0]
            : null; // Inicializa la talla seleccionada con la primera opción
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[600],
        title: Text(widget.productName),
      ),
      body: Center(
        // Envuelve todo el contenido en un Center
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            // Asegura que todo el contenido sea desplazable
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment
                      .center, // Centra los elementos en el eje vertical
              crossAxisAlignment:
                  CrossAxisAlignment
                      .center, // Centra los elementos en el eje horizontal
              children: [
                SizedBox(height: 20),
                Image.asset(widget.imagePath, height: 250),
                SizedBox(height: 10),
                Text(
                  widget.productName,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center, // Centra el texto
                ),
                Text(
                  '\$${widget.price.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  textAlign: TextAlign.center, // Centra el texto
                ),
                SizedBox(height: 20),
                Text(
                  'Tallas disponibles:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center, // Centra el texto
                ),
                SizedBox(height: 10),
                DropdownButton<String>(
                  value: selectedSize,
                  onChanged: (String? newSize) {
                    setState(() {
                      selectedSize = newSize;
                    });
                  },
                  items:
                      widget.sizes
                          .map(
                            (size) => DropdownMenuItem<String>(
                              value: size,
                              child: Text(size),
                            ),
                          )
                          .toList(),
                  hint: Text("Selecciona una talla"),
                  isExpanded: true,
                  underline: Container(),
                ),
                SizedBox(height: 20),
                Text(
                  'Color disponible:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center, // Centra el texto
                ),
                Text(
                  widget.color,
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ), // Centra el texto
                SizedBox(height: 20),
                Text(
                  'Stock disponible: ${widget.stock}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center, // Centra el texto
                ),
                SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed:
                      selectedSize != null
                          ? () {
                            final item = CartModel(
                              image: widget.imagePath,
                              name: widget.productName,
                              price: widget.price,
                              size: selectedSize!,
                            );
                            widget.onAddToCart(item);
                            Navigator.pop(
                              context,
                            ); // Volver a la pantalla anterior
                          }
                          : null,
                  icon: Icon(Icons.shopping_cart),
                  label: Text('Agregar al carrito'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
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

  CartModel({
    required this.image,
    required this.name,
    required this.size,
    required this.price,
  });
}

class CartScreen extends StatelessWidget {
  final List<CartModel> cartItems;
  final Function(String address) onConfirm;
  const CartScreen({Key? key, required this.cartItems, required this.onConfirm})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return cartItems.isEmpty
        ? const Center(child: Text('El carrito está vacío.'))
        : Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return ListTile(
                    leading: Image.asset(item.image),
                    title: Text(item.name),
                    subtitle: Text(
                      'Talla: ${item.size} - \$${item.price.toStringAsFixed(2)}',
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => CheckoutScreen(
                            cartItems: cartItems,
                            onConfirm: onConfirm,
                          ),
                    ),
                  );
                },
                child: const Text('Continuar con el pago'),
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

  String? _paymentMethod;
  final List<String> _methods = ['Visa', 'MasterCard'];

  void _confirmOrder() {
    if (_streetController.text.isEmpty ||
        _numberController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _postalCodeController.text.isEmpty ||
        _paymentMethod == null ||
        _cardNumberController.text.isEmpty ||
        _expiryDateController.text.isEmpty ||
        _cvvController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos.')),
      );
      return;
    }

    final address =
        '${_streetController.text} #${_numberController.text}, ${_cityController.text}, CP ${_postalCodeController.text}';

    widget.onConfirm(address);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos de envío y pago'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Dirección de entrega',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _streetController,
              decoration: const InputDecoration(labelText: 'Calle'),
            ),
            TextField(
              controller: _numberController,
              decoration: const InputDecoration(labelText: 'Número'),
            ),
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(labelText: 'Ciudad'),
            ),
            TextField(
              controller: _postalCodeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Código Postal'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Método de pago',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
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
                labelText: 'Selecciona método',
              ),
            ),
            const SizedBox(height: 10),
            if (_paymentMethod != null) ...[
              TextField(
                controller: _cardNumberController,
                decoration: const InputDecoration(
                  labelText: 'Número de tarjeta',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _expiryDateController,
                decoration: const InputDecoration(
                  labelText: 'Fecha de vencimiento (MM/YY)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _cvvController,
                decoration: const InputDecoration(
                  labelText: 'CVV',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
              ),
            ],
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle),
              label: const Text('Confirmar pedido'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: _confirmOrder,
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------- PERFIL -------------------------

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          const Text(
            'Datos de cuenta',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Usuario: ${UserData().username}'),
          ),
          ListTile(
            leading: Icon(Icons.email),
            title: Text('Correo: ${UserData().email}'),
          ),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Contraseña: ${UserData().password}'),
          ),
          const SizedBox(height: 20),
          const Text(
            'Ayuda / Preguntas frecuentes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const ListTile(
            leading: Icon(Icons.help_outline),
            title: Text('¿Dónde está mi pedido?'),
          ),
          const ListTile(
            leading: Icon(Icons.help_outline),
            title: Text('¿Cómo cancelar un pedido?'),
          ),
          const ListTile(
            leading: Icon(Icons.help_outline),
            title: Text('¿Cómo cambiar la contraseña?'),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            icon: Icon(Icons.logout),
            label: Text('Cerrar sesión'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: Size.fromHeight(50),
            ),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => SplashScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
