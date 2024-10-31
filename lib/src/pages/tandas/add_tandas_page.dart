import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:frontend_movil_muni/infraestructure/models/inventario/bodegas_model.dart';
import 'package:frontend_movil_muni/infraestructure/models/inventario/producto_model.dart';
import 'package:frontend_movil_muni/infraestructure/models/inventario/ubicaciones_model.dart';
import 'package:frontend_movil_muni/src/widgets/generic_select_input.dart';
import 'package:frontend_movil_muni/src/widgets/generic_text_input.dart';
import 'package:frontend_movil_muni/src/providers/inventario/inventario_provider.dart';
import 'package:frontend_movil_muni/src/providers/inventario/mixin/socket/socket_inventario_provider.dart';
import 'package:frontend_movil_muni/src/widgets/custom_date_input.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AddTandasPage extends StatefulWidget {
  const AddTandasPage({super.key});

  @override
  State<AddTandasPage> createState() => _AddTandasPageState();
}

class _AddTandasPageState extends State<AddTandasPage> {
  final formKey = GlobalKey<ShadFormState>();
  final TextEditingController fechaController = TextEditingController();
  bool isInvalidDate = false;
  String? selectedUbicacion;
  Timer? _disposeTimer;

  late InventarioProvider _inventarioProvider;
  Map<String, SelectionProductModel> mapearListaAProductoMap(
      List<SelectionProductModel> productos) {
    return {for (var producto in productos) producto.id: producto};
  }

  @override
  void initState() {
    super.initState();
    _inventarioProvider = context.read<InventarioProvider>();
    _inventarioProvider
        .connect([InventarioEvent.getProductos, InventarioEvent.getAllBodegas]);
  }

  @override
  void dispose() {
    _inventarioProvider.disposeFormularioTandaData();

    // Iniciar un temporizador de 1 segundo antes de limpiar
    _disposeTimer = Timer(const Duration(seconds: 1), () {
      _inventarioProvider.disconnect(
          [InventarioEvent.getProductos, InventarioEvent.getAllBodegas]);
    });
    // _inventarioProvider.disconnect(
    //     [InventarioEvent.getProductos, InventarioEvent.getAllBodegas]);
    // _inventarioProvider.disposeFormularioTandaData();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Cancelar el temporizador de limpieza si la vista se "reabre" antes de que expire
    if (_disposeTimer != null && _disposeTimer!.isActive) {
      _disposeTimer!.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyles = ShadTheme.of(context).textTheme;
    final inventarioProvider = context.watch<InventarioProvider>();
    final isLoading = inventarioProvider.loadingProductos ||
        inventarioProvider.loadingBodegas;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.blue[500],
        title: Text(
          'Añadir Tanda',
          style: textStyles.h4.copyWith(
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Stack(
                children: [
                  ShadForm(
                    key: formKey,
                    child: ListView(
                      children: [
                        //?Producto input - select
                        GenericSelectInput<SelectionProductModel>(
                          padding: 20,
                          items: inventarioProvider
                              .productosSelection, // Usamos directamente la lista de productos
                          displayField: (producto) => producto
                              .nombre, // Mostramos el nombre del producto
                          onChanged: (String? value) {
                            if (value != null) {
                              final producto = inventarioProvider
                                  .productosSelection
                                  .firstWhere(
                                (u) => u.nombre == value,
                                orElse: () => SelectionProductModel
                                    .getNull(), // Aquí puedes manejar lo que ocurre si no encuentra el producto
                              );

                              if (producto.id != '') {
                                inventarioProvider.setFormularioTandaData(
                                    'idProducto', producto.id);
                              }
                            }
                          },

                          fieldId: 'producto',
                          labelText: 'Producto',
                          placeholderText: 'Seleccionar producto...',
                          searchPlaceholderText: 'Buscar producto',
                        ),

                        //?Cantidad
                        GenericTextInput(
                          id: 'cantidad',
                          labelText: 'Cantidad',
                          validator: (v) {
                            if (v.isEmpty) {
                              return 'Ingrese una Cantidad';
                            }
                            return null;
                          },
                          placeHolder: '200...',
                          inputType: TextInputType.number,
                          onChanged: (value) {
                            if (value == '') {
                              if (inventarioProvider.formularioTandaData[
                                      'cantidadIngresada'] !=
                                  null) {
                                inventarioProvider.setFormularioTandaData(
                                  'cantidadIngresada',
                                  null,
                                );
                              }
                              return;
                            }
                            inventarioProvider.setFormularioTandaData(
                              'cantidadIngresada',
                              int.parse(value!),
                            );
                          },
                        ),
                        //?Vencimiento
                        CustomDateInput(
                          id: 'fecha',
                          controller: fechaController,
                          label: 'Fecha de vencimiento',
                          validator: (String? errorsDate) {
                            setState(() {
                              isInvalidDate = errorsDate != null;
                            });
                            if (errorsDate != '') {
                              if (inventarioProvider.formularioTandaData[
                                      'fechaVencimiento'] !=
                                  null) {
                                inventarioProvider.setFormularioTandaData(
                                  'fechaVencimiento',
                                  null,
                                );
                              }
                              return;
                            }
                            List<String> fechaSplitted =
                                fechaController.value.text.split('-');
                            String fecha =
                                '${fechaSplitted[2]}-${fechaSplitted[1]}-${fechaSplitted[0]}';

                            inventarioProvider.setFormularioTandaData(
                              'fechaVencimiento',
                              fecha,
                            );
                          },
                        ),
                        //?Bodega
                        SelectListBodega(
                          labelText: 'Bodega',
                          lista: inventarioProvider.bodegas,
                          nombre: 'Bodegas ⤵️',
                          onBodegaChanged: (String selectedBodegaId) {
                            // Actualizar formularioTandaData con el ID de la bodega seleccionada
                            inventarioProvider.setFormularioTandaData(
                                'idBodega', selectedBodegaId);

                            // Emitir el evento para obtener las ubicaciones
                            inventarioProvider
                                .connect([InventarioEvent.getUbicaciones]);
                          },
                        ),

                        //?Ubicacion
                        GenericSelectInput<UbicacionesModel>(
                          padding: 20,
                          items: inventarioProvider
                              .ubicaciones, // Usamos directamente la lista de productos
                          displayField: (ubicacion) => ubicacion
                              .descripcion, // Mostramos el nombre del producto
                          onChanged: (String? value) {
                            if (value != null) {
                              final ubicacion =
                                  inventarioProvider.ubicaciones.firstWhere(
                                (u) => u.descripcion == value,
                                orElse: () => UbicacionesModel
                                    .getNull(), // Aquí puedes manejar lo que ocurre si no encuentra el producto
                              );

                              if (ubicacion.id != '') {
                                setState(() {
                                  selectedUbicacion =
                                      value; // Guardamos el id seleccionado
                                });
                                inventarioProvider.setFormularioTandaData(
                                    'idUbicacion', ubicacion.id);
                              }
                            }
                          },
                          initialValue: selectedUbicacion,
                          fieldId: 'ubicacion',
                          labelText: 'Ubicacion',
                          placeholderText: 'Seleccionar ubicacion...',
                          searchPlaceholderText: 'Buscar ubicacion',
                        ),
                      ],
                    ),
                  ),
                  _AddButtonTanda(
                    formKey: formKey,
                  )
                ],
              ),
            ),
    );
  }
}

class SelectListBodega extends StatefulWidget {
  const SelectListBodega({
    super.key,
    required this.lista,
    required this.nombre,
    required this.onBodegaChanged,
    required this.labelText,
  });
  final List<BodegaModel> lista;
  final String nombre;
  final String labelText;
  final void Function(String idBodega) onBodegaChanged;

  @override
  State<SelectListBodega> createState() => _SelectListBodegaState();
}

class _SelectListBodegaState extends State<SelectListBodega> {
  String? _selectedBodegaId; // Para almacenar el valor actual de la bodega
  bool _hasInitialEmitted = false; // Para evitar la emisión repetida
  @override
  void initState() {
    super.initState();
    // Captura el valor inicial al renderizar el widget solo una vez
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.lista.isNotEmpty && !_hasInitialEmitted) {
        setState(() {
          _selectedBodegaId = widget.lista[0].id;
          widget.onBodegaChanged(_selectedBodegaId!); // Emitir solo una vez
          _hasInitialEmitted = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final textStyles = ShadTheme.of(context).textTheme;
    final colors = ShadTheme.of(context).colorScheme;
    return FadeInLeft(
      delay: const Duration(milliseconds: 600),
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
          ShadSelectFormField<String>(
            id: 'bodega',
            decoration: ShadDecoration(
              errorLabelStyle: textStyles.p,
              labelStyle: textStyles.p,
            ),
            minWidth: size.width - 20,
            // label: Padding(
            //   padding: EdgeInsets.only(left: 5),
            //   child: Text(widget.labelText),
            // ),
            initialValue: widget.lista[0].id,
            placeholder: const Text('Seleccionar bodegas'),
            options: [
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 6, 6, 6),
                child: Text(
                  widget.nombre,
                  style: textStyles.muted.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.popoverForeground,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              ...widget.lista.map((e) => ShadOption(
                  value: e.id, child: Text("${e.nombre} - ${e.direccion}")))
            ],
            onChanged: (newValue) {
              if (newValue != _selectedBodegaId) {
                setState(() {
                  _selectedBodegaId = newValue;
                });
                if (newValue == null) {
                  return;
                }
                widget.onBodegaChanged(newValue); // Emitir solo si cambia
              }
            },
            selectedOptionBuilder: (context, value) {
              for (var bodega in widget.lista) {
                if (bodega.id == value) {
                  return Row(
                    children: [
                      const Icon(MdiIcons.mapMarkerRadiusOutline),
                      Text('${bodega.nombre} - ${bodega.direccion}'),
                    ],
                  );
                }
              }
              return const Text('Selecciona una opción');
            },
          ),
        ],
      ),
    );
  }
}

class _AddButtonTanda extends StatefulWidget {
  final GlobalKey<ShadFormState> formKey;
  const _AddButtonTanda({
    required this.formKey,
  });

  @override
  State<_AddButtonTanda> createState() => _AddButtonTandaState();
}

class _AddButtonTandaState extends State<_AddButtonTanda> {
  @override
  Widget build(BuildContext context) {
    final inventarioProvider = context.watch<InventarioProvider>();
    Size size = MediaQuery.of(context).size;
    final textStyles = ShadTheme.of(context).textTheme;
    return Positioned(
      bottom: 10.0,
      left: 5.0,
      right: 5.0,
      child: ShadButton(
          enabled: !inventarioProvider.creatingTanda,
          icon: !inventarioProvider.creatingTanda
              ? Container()
              : Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),
          onPressed: () async {
            // setState(() {
            //   selectedProductId = 'Cuchara de Mesa';
            // });

            // WidgetsBinding.instance.addPostFrameCallback((_) {
            //   formKey.currentState?.fields['producto']?.reset();
            // });

            // formKey.currentState!.saveAndValidate();
            // print(inventarioProvider.formularioTandaData);
            if (!widget.formKey.currentState!.saveAndValidate()) {
              return;
            }

            // WidgetsBinding.instance.addPostFrameCallback((_) {
            //   context.push('/tandas/add');
            // });

            // widget.formKey.currentState?.fields['bodega']?.reset();

            await inventarioProvider
                .addTanda(inventarioProvider.formularioTandaData);
            String productName = '';

            for (final producto in inventarioProvider.productosSelection) {
              if (inventarioProvider.formularioTandaData['idProducto'] ==
                  producto.id) {
                productName = producto.nombre;
                break;
              }
            }
            if (!context.mounted) {
              return;
            }
            ShadToaster.of(context).show(
              ShadToast(
                // padding: EdgeInsets.only(bottom: size.height * 0.1),
                offset: Offset(size.width * 0.05, size.height * 0.1),

                backgroundColor: Colors.green[400],
                alignment: Alignment.bottomRight,
                title: Text(
                  'Tanda creada',
                  style: textStyles.p.copyWith(
                    color: Colors.white,
                  ),
                ),
                description: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.centerRight,
                  children: [
                    Positioned(
                      top: -size.height * 0.042,
                      right: -size.width * 0.3,
                      child: Icon(
                        MdiIcons.checkCircle,
                        color: Colors.white,
                        size: size.width * 0.15,
                      ),
                    ),
                    Text(
                      'Se ha creado tanda de $productName',
                      style: textStyles.small.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                duration: Duration(seconds: 4),
              ),
            );
            context.pop(true);
          },
          child:
              Text(!inventarioProvider.creatingTanda ? 'Añadir' : 'Cargando')),
    );
  }
}
