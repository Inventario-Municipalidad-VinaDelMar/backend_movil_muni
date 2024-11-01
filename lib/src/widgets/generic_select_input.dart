import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class GenericSelectInput<T> extends StatefulWidget {
  const GenericSelectInput({
    super.key,
    required this.items,
    required this.displayField,
    this.placeholderText = 'Seleccionar elemento...',
    this.errorText = 'Por favor, selecciona un elemento',
    this.searchPlaceholderText = 'Buscar...',
    this.onChanged,
    this.initialValue,
    required this.labelText,
    required this.fieldId,
    required this.padding,
  });
  final double padding;
  final String fieldId;
  final String errorText;
  final String labelText;
  final String? initialValue;
  final List<T> items; // Lista de elementos a seleccionar
  final String Function(T)
      displayField; // Función para mostrar el nombre del elemento
  final void Function(String?)?
      onChanged; // Callback al seleccionar un elemento
  final String placeholderText;
  final String searchPlaceholderText;

  @override
  State<GenericSelectInput<T>> createState() => _GenericSelectInputState<T>();
}

class _GenericSelectInputState<T> extends State<GenericSelectInput<T>> {
  var searchValue = '';
  String? selectedValue;
  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue; // Inicializamos con el valor pasado
  }

  // Filtrar los elementos de acuerdo al valor buscado
  List<T> get filteredItems => widget.items
      .where((item) => widget
          .displayField(item)
          .toLowerCase()
          .contains(searchValue.toLowerCase()))
      .toList();

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
              widget.labelText,
              style: textStyles.p,
            ),
          ),
          ShadSelectFormField<String>.withSearch(
            id: widget.fieldId,
            decoration: ShadDecoration(
              errorLabelStyle: textStyles.p,
              labelStyle: textStyles.p,
            ),
            minWidth: size.width - widget.padding,
            placeholder: Text(widget.placeholderText),
            onSearchChanged: (value) => setState(() {
              searchValue = value;
            }),
            searchPlaceholder: Text(widget.searchPlaceholderText),
            options: [
              if (filteredItems.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text('No se encontraron elementos...'),
                ),
              ...filteredItems.map((item) {
                final itemKey = widget.displayField(item);
                return ShadOption(
                  value: itemKey,
                  child: Text(itemKey),
                );
              }),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return widget.errorText;
              }
              // if ((value == null || value.isEmpty) &&
              //     (widget.initialValue != null)) {
              //   return 'Por favor, selecciona un elemento';
              // }
              return null;
            },
            error: (error) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(error),
              );
            },
            onReset: () {
              if (widget.initialValue == null) {
                return;
              }
              setState(() {
                selectedValue = widget
                    .initialValue; // Actualizamos el valor seleccionado en el estado
              });
              if (widget.onChanged != null) {
                widget.onChanged!(widget.initialValue); // Notificamos el cambio
              }
            },
            initialValue: selectedValue,
            onChanged: (value) {
              setState(() {
                selectedValue =
                    value; // Actualizamos el valor seleccionado en el estado
              });
              if (widget.onChanged != null) {
                widget.onChanged!(value); // Notificamos el cambio
              }
            },
            selectedOptionBuilder: (context, value) {
              final selectedItem = widget.items
                  .firstWhere((item) => widget.displayField(item) == value);
              return Text(widget.displayField(selectedItem));
            },
          ),
        ],
      ),
    );
  }
}
