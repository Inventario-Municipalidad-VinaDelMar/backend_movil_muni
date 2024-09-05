import 'package:flutter/material.dart';

class AddTandasPage extends StatefulWidget {
  const AddTandasPage({super.key});

  @override
  State<AddTandasPage> createState() => _AddTandasPageState();
}

class _AddTandasPageState extends State<AddTandasPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Tanda'),
      ),
      body: Stack(
        children: [ListView(), BotonAgregar()],
      ),
    );
  }
}

class BotonAgregar extends StatelessWidget {
  const BotonAgregar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 10.0,
      left: 10.0,
      right: 10.0,
      child: ElevatedButton(
        onPressed: () {
          print('Añadir');
        },
        child: Text('Añadir'),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16.0),
        ),
      ),
    );
  }
}
