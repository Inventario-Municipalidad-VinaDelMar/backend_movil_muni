import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class DateTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (oldValue.text.length > newValue.text.length) {
      return newValue;
    }
    final buffer = StringBuffer();
    if (text.length >= 2) {
      buffer.write('${text.substring(0, 2)}-');
      if (text.length > 2) {
        if (text.length >= 4) {
          buffer.write('${text.substring(2, 4)}-');
          if (text.length > 4) {
            final end = text.length > 8 ? 8 : text.length;
            buffer.write(text.substring(4, end));
          }
        } else {
          buffer.write(text.substring(2));
        }
      }
    } else {
      buffer.write(text);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class CustomDateInput extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final void Function(String?) validator;

  const CustomDateInput(
      {super.key,
      required this.label,
      required this.validator,
      required this.controller});

  @override
  State<CustomDateInput> createState() => _CustomDateInputState();
}

class _CustomDateInputState extends State<CustomDateInput> {
  // final TextEditingController _controller = TextEditingController();
  String _errorText = "";
  bool _hasInitialValue = false;
  String errorValidate = "";

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTextChange);
    widget.controller.value.text;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChange);
    widget.controller.dispose();
    super.dispose();
  }

  void _handleTextChange() {
    if (!_hasInitialValue && widget.controller.text.isNotEmpty) {
      _hasInitialValue = true;
    }
  }

  void _validateDate(
    BuildContext context,
    String value,
  ) {
    setState(() {
      _errorText = '';
      final parts = value.split('-');
      if (parts.length != 3) {
        _errorText = 'Fecha no válida';
        return;
      }

      final day = int.tryParse(parts[0]) ?? 0;
      final month = int.tryParse(parts[1]) ?? 0;
      final year = int.tryParse(parts[2]) ?? 0;

      final errors = <String>[];

      /*CORREGIR DIAS 31 EN MESES QUE NO TIENEN 31 DIAS */

      if (day < 1 || day > 31) {
        errors.add('Día no válido');
      }
      if ((month < 1 || month > 12) && errors.isEmpty) {
        errors.add('Mes no válido');
      }
      if ((year < DateTime.now().year) && errors.isEmpty) {
        errors.add('El año minimo debe ser ${DateTime.now().year}');
      }
      // if (year > DateTime.now().year + 3) {
      //   errors.add('Maximo año: 2027');
      // }
      final now = DateTime.now();
      DateTime selectedDate = DateTime(year, month, day);
      if (selectedDate.isBefore(now) && errors.isEmpty) {
        errors.add('Esta no es una fecha futura.');
      }

      if (errors.isNotEmpty) {
        _errorText = errors.join(', ');
        errorValidate = errors.join(', ');
      }
    });

    widget.validator(_errorText);
  }

  @override
  Widget build(BuildContext context) {
    final colors = ShadTheme.of(context).colorScheme;
    return FadeInLeft(
      delay: const Duration(milliseconds: 400),
      duration: const Duration(milliseconds: 200),
      child: ShadInputFormField(
        validator: (v) {
          if (_errorText != "") {
            setState(() {
              errorValidate = _errorText;
            });
            return "";
          }
          if (v.isEmpty) {
            setState(() {
              errorValidate = 'Selecciona una fecha';
            });

            return "";
          }

          return null;
        },
        placeholder: Text(widget.label),
        error: (error) {
          print(error);
          return errorValidate != ""
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    errorValidate,
                    style: TextStyle(color: colors.destructive),
                  ))
              : Container();
        },
        keyboardType: TextInputType.emailAddress,
        controller: widget.controller,
        inputFormatters: [DateTextInputFormatter()],
        onChanged: (p0) => _validateDate(context, p0),
        onPressed: () {
          if (!_hasInitialValue && widget.controller.text.isEmpty) {
            setState(() {
              widget.controller.text = '0';
              _hasInitialValue = true;
            });
          }
        },
      ),
    );
  }
}
