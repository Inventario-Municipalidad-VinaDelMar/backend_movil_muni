import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

showToaster(BuildContext context, String description, String title) {
  Size size = MediaQuery.of(context).size;

  ShadToaster.of(context).show(
    ShadToast(
      offset: Offset(size.width * 0.05, size.height * 0.1),
      backgroundColor: Colors.green[400],
      title: Text(title),
      description: Text(description),
      action: ShadButton.outline(
        child: const Text('Ok'),
        onPressed: () => ShadToaster.of(context).hide(),
      ),
    ),
  );
}
