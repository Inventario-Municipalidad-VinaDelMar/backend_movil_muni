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

  final int maxLines;
  final int? maxLength;
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
    this.maxLength,
    this.maxLines = 1,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final textStyles = ShadTheme.of(context).textTheme;
    return FadeInLeft(
      duration: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              labelText,
              style: textStyles.p,
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: size.width * 0.9,
            ),
            child: ShadInputFormField(
              maxLines: maxLines,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              id: id,
              decoration: ShadDecoration(
                errorLabelStyle: textStyles.p,
                labelStyle: textStyles.p,
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
              inputFormatters: [
                if (inputFormatters != null) ...inputFormatters!,
                if (maxLength != null)
                  LengthLimitingTextInputFormatter(maxLength),
              ],
              onPressed: onPressed,
              placeholder: Text(placeHolder),
              keyboardType: inputType,
              onChanged: onChanged,
            ),
          ),
          if (maxLength !=
              null) // Solo muestra el contador si maxLength no es null
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller ?? TextEditingController(),
              builder: (context, value, child) {
                final currentLength = value.text.length;
                return Padding(
                  padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                  child: Text(
                    '$currentLength/$maxLength',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
