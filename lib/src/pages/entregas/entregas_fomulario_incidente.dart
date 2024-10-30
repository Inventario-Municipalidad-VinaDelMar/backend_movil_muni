import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class EntregasFormularioIncidente extends StatelessWidget {
  final String idEnvio;
  const EntregasFormularioIncidente({
    super.key,
    required this.idEnvio,
  });

  @override
  Widget build(BuildContext context) {
    final textStyles = ShadTheme.of(context).textTheme;
    return Scaffold(
      backgroundColor:
          Colors.grey[200], // Cambiamos el fondo a un color más suave
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue[600],
        title: Text(
          'Incidente durante envío',
          style: textStyles.h4.copyWith(
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: Text('Crear incidente para $idEnvio'),
      ),
    );
  }
}
