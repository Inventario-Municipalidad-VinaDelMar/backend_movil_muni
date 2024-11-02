import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class EmptyFullScreen extends StatelessWidget {
  final String emptyMessage;
  const EmptyFullScreen({super.key, required this.emptyMessage});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final textStyles = ShadTheme.of(context).textTheme;
    return ZoomIn(
      duration: const Duration(milliseconds: 200),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: size.height * 0.25,
              child: Image.asset(
                'assets/logos/empty.png', // Cambié la imagen a una versión más estilizada
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              emptyMessage,
              style: textStyles.p.copyWith(color: Colors.grey[500]),
            ),
            const SizedBox(height: 20),
            ShadButton(
              size: ShadButtonSize.lg,
              onPressed: () => context.pop(),
              child: Text(
                'Volver atrás',
              ),
            ),
            SizedBox(height: size.height * 0.16),
          ],
        ),
      ),
    );
  }
}
