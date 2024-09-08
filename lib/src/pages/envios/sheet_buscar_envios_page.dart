import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shadcn_ui/src/components/sheet.dart';

class SheetBuscarEnviosPage extends StatelessWidget {
  const SheetBuscarEnviosPage({super.key, required this.side});

  final ShadSheetSide side;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    Size size = MediaQuery.of(context).size;
    //final colors = ShadTheme.of(context).colorScheme;
    final textStyles = ShadTheme.of(context).textTheme;

    return ShadSheet(
      constraints: side == ShadSheetSide.left || side == ShadSheetSide.right
          ? const BoxConstraints(maxWidth: 512)
          : null,
      title: Text('Fideos Corbata Carrozi', style: textStyles.h3),
      actions: [
        ShadButton(
          size: ShadButtonSize.sm,
          onPressed: () {
            context.pop();
          },
          icon: FaIcon(
            FontAwesomeIcons.check,
            size: size.height * 0.025,
          ),
          child: Text(
            'Confirmar',
            style: textStyles.h4.copyWith(color: Colors.white),
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: ShadInputFormField(
          id: 'Descuento',
          label: Text('Cantidad a Retirar', style: textStyles.h4),
          placeholder: const Text('Ingrese la cantiadad a retira'),
          keyboardType: TextInputType.number,
          description: const Text('Cantidad maxima 500'),
          validator: (v) {},
        ),
      ),
    );
  }
}
