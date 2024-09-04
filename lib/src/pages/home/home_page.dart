import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = ShadTheme.of(context).colorScheme;
    final textStyles = ShadTheme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio', style: textStyles.h1),
      ),
      body: const Center(
        child: Text(
          'HomePage',
        ),
      ),
    );
  }
}
