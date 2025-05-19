import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  final Function(String) onPaymentConfirmed;

  const CheckoutScreen({Key? key, required this.onPaymentConfirmed})
    : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  final TextEditingController streetController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Método de Pago")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                "Método de pago (Visa o MasterCard)",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: cardNumberController,
                decoration: InputDecoration(labelText: "Número de tarjeta"),
                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        value!.isEmpty ? "Ingresa el número de tarjeta" : null,
              ),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Nombre del titular"),
                validator:
                    (value) =>
                        value!.isEmpty ? "Ingresa el nombre del titular" : null,
              ),
              TextFormField(
                controller: expiryController,
                decoration: InputDecoration(labelText: "Fecha de vencimiento"),
                validator:
                    (value) => value!.isEmpty ? "Ingresa la fecha" : null,
              ),
              TextFormField(
                controller: cvvController,
                decoration: InputDecoration(labelText: "CVV"),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Ingresa el CVV" : null,
              ),
              SizedBox(height: 20),
              Text(
                "Dirección de entrega",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: streetController,
                decoration: InputDecoration(labelText: "Calle"),
                validator:
                    (value) => value!.isEmpty ? "Ingresa la calle" : null,
              ),
              TextFormField(
                controller: numberController,
                decoration: InputDecoration(labelText: "Número"),
                validator:
                    (value) => value!.isEmpty ? "Ingresa el número" : null,
              ),
              TextFormField(
                controller: cityController,
                decoration: InputDecoration(labelText: "Ciudad"),
                validator:
                    (value) => value!.isEmpty ? "Ingresa la ciudad" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final address =
                        "${streetController.text}, ${numberController.text}, ${cityController.text}";
                    widget.onPaymentConfirmed(address);
                    Navigator.pop(
                      context,
                    ); // Esto regresa a HomeScreen y activa el método
                  }
                },
                child: Text("Confirmar pago"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
