import 'package:flutter/material.dart';

showAlertDialog(
    BuildContext context, String description, Function()? continueFunction) {
  Widget continueButton = TextButton(
    child: const Text("Aceptar"),
    onPressed: continueFunction,
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Confirmación"),
    content: Text(description),
    actions: [
      TextButton(
        child: Text("Cancelar"),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      continueButton,
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
