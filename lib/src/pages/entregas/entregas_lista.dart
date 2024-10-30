import 'package:flutter/material.dart';

class EntregasLista extends StatelessWidget {
  final String idEnvio;
  const EntregasLista({
    super.key,
    required this.idEnvio,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Entregas lista'),
      ),
      body: Center(
        child: Text('Lista de entregas de: $idEnvio'),
      ),
    );
  }
}
