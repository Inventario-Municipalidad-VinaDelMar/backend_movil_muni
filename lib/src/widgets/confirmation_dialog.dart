import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

Future<void> showAlertDialog({
  required BuildContext context,
  required String description,
  required Function()? continueFunction,
  // required String entityToCreate,
}) async {
  Widget continueButton = ShadButton(
    onPressed: () async {
      if (continueFunction == null) {
        return;
      }
      continueFunction();
      context.pop();
    },
    child: const Text('Confirmar'),
  );
  Size size = MediaQuery.of(context).size;
  final dialog = ShadDialog.alert(
    constraints: BoxConstraints(
      maxWidth: size.width * 0.9,
    ),
    removeBorderRadiusWhenTiny: false,
    radius: BorderRadius.circular(15),
    title: const Text('¿Esta seguro de continuar?'),
    description: Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        description,
      ),
    ),
    actions: [
      ShadButton.outline(
        child: const Text('Cancelar'),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      continueButton,
    ],
  );

  await showShadDialog(
    context: context,
    builder: (context) => dialog,
  );
}
