import 'package:flutter/material.dart';

class Carrito extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Carrito de compras')),
      body: Column(children: <Widget>[Text('Estamos en carrito')]),
    );
  }
}
