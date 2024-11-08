import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

showToaster(BuildContext context, String description, String title) {
  ShadToaster.of(context).show(
    ShadToast(
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
