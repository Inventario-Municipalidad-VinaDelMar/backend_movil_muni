import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class GenericTextInput extends StatelessWidget {
  final String id;
  final String labelText;
  final String placeHolder;
  final void Function(String?)? onChanged;
  final void Function()? onPressed;
  final String? Function(String)? validator;
  final Widget Function(String)? error;
  final TextInputType inputType;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  const GenericTextInput({
    super.key,
    required this.labelText,
    required this.placeHolder,
    this.onChanged,
    this.inputType = TextInputType.text,
    this.validator,
    this.controller,
    this.error,
    this.onPressed,
    this.inputFormatters,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    final textStyles = ShadTheme.of(context).textTheme;
    return FadeInLeft(
      duration: const Duration(milliseconds: 200),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: ShadInputFormField(
          id: id,
          decoration: ShadDecoration(
            errorLabelStyle: textStyles.p,
            labelStyle: textStyles.p,
          ),
          label: Padding(
            padding: EdgeInsets.only(left: 5),
            child: Text(labelText),
          ),
          validator: validator,
          error: error ??
              (error) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(error),
                );
              },
          controller: controller,
          inputFormatters: inputFormatters,
          onPressed: onPressed,
          placeholder: Text(placeHolder),
          keyboardType: inputType,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
