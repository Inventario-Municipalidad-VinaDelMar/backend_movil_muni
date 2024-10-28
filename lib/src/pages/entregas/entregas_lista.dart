import 'package:flutter/material.dart';

class EntregasLista extends StatelessWidget {
  const EntregasLista({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Entregas lista'),
      ),
      body: Center(
        child: Text('Lista de entregas'),
      ),
    );
  }
}
