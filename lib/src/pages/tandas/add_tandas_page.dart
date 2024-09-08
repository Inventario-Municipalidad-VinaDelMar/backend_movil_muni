import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:frontend_movil_muni/infraestructure/models/bodegas_model.dart';
import 'package:frontend_movil_muni/infraestructure/models/producto_model.dart';
import 'package:frontend_movil_muni/infraestructure/models/ubicaciones_model.dart';
import 'package:frontend_movil_muni/src/providers/inventario/inventario_provider.dart';
import 'package:frontend_movil_muni/src/providers/inventario/mixin/socket/socket_inventario_provider.dart';
import 'package:frontend_movil_muni/src/utils/date_text.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AddTandasPage extends StatefulWidget {
  const AddTandasPage({super.key});

  @override
  State<AddTandasPage> createState() => _AddTandasPageState();
}

class _AddTandasPageState extends State<AddTandasPage> {
  TextEditingController fechaController = TextEditingController();
  bool isInvalidDate = false;
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
    _inventarioProvider.disconnect([InventarioEvent.getProductos]);
    _inventarioProvider.disposeFormularioTandaData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventarioProvider = context.watch<InventarioProvider>();
    final isLoading = inventarioProvider.loadingProductos ||
        inventarioProvider.loadingBodegas;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Tanda'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Stack(
                children: [
                  ListView(
                    children: [
                      HeadRowTextForm(
                        texto: 'Producto:',
                        funcionOnPressed: () {},
                      ),
                      //?Producto
                      SelectSearch(
                        productosSelection: mapearListaAProductoMap(
                          inventarioProvider.productosSelection,
                        ),
                      ),
                      const HeadTextForm(
                        texto: 'Cantidad: ',
                      ),
                      //?Cantidad
                      FadeInLeft(
                        duration: const Duration(milliseconds: 200),
                        delay: const Duration(milliseconds: 200),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 320),
                          child: ShadInput(
                            placeholder: const Text('200...'),
                            keyboardType: TextInputType.number,
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
                                value,
                              );
                            },
                          ),
                        ),
                      ),

                      //?Vencimiento
                      const HeadTextForm(
                        texto: 'Fecha de vencimiento: ',
                      ),
                      CustomDateInput(
                        label: 'Fecha de vencimiento...',
                        validator: (String? errorsDate) {
                          setState(() {
                            isInvalidDate = errorsDate != null;
                          });
                          if (errorsDate != '') {
                            if (inventarioProvider
                                    .formularioTandaData['fechaVencimiento'] !=
                                null) {
                              inventarioProvider.setFormularioTandaData(
                                'fechaVencimiento',
                                null,
                              );
                            }
                            return;
                          }
                          inventarioProvider.setFormularioTandaData(
                            'fechaVencimiento',
                            fechaController.value.text,
                          );
                        },
                        controller: fechaController,
                      ),

                      //?Bodega
                      const HeadTextForm(
                        texto: 'Bodega: ',
                      ),
                      SelectListBodega(
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
                      HeadRowTextForm(
                        texto: 'Ubicación: ',
                        funcionOnPressed: () {},
                      ),
                      SelectListUbicacion(
                        lista: inventarioProvider.ubicacion,
                        nombre: 'Ubicaciones ⤵️',
                      ),
                    ],
                  ),
                  const BotonAgregar()
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
  });
  final List<BodegaModel> lista;
  final String nombre;
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
    final textStyles = ShadTheme.of(context).textTheme;
    final colors = ShadTheme.of(context).colorScheme;
    return FadeInLeft(
      delay: const Duration(milliseconds: 600),
      duration: const Duration(milliseconds: 200),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 180),
        child: ShadSelect<String>(
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
      ),
    );
  }
}

class SelectListUbicacion extends StatelessWidget {
  const SelectListUbicacion({
    super.key,
    required this.lista,
    required this.nombre,
  });
  final List<UbicacionesModel> lista;
  final String nombre;
  @override
  Widget build(BuildContext context) {
    final textStyles = ShadTheme.of(context).textTheme;
    final colors = ShadTheme.of(context).colorScheme;
    final inventarioProvider = context.watch<InventarioProvider>();
    if (inventarioProvider.loadingUbicacion) {
      return FadeOutDown(
        duration: const Duration(milliseconds: 200),
        child: Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Cargando ubicaciones',
                style: textStyles.small,
              ),
              const SizedBox(width: 20),
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return FadeInUp(
      from: 25,
      delay: const Duration(milliseconds: 300),
      duration: const Duration(milliseconds: 400),
      child: ShadSelect<String>(
        placeholder: const Text('Seleccionar ubicaciones'),
        options: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 6, 6, 6),
            child: Text(
              nombre,
              style: textStyles.muted.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.popoverForeground,
              ),
              textAlign: TextAlign.start,
            ),
          ),
          ...lista.map(
            (u) => ShadOption(
              value: u.id,
              child: Text(u.descripcion),
            ),
          )
        ],
        onChanged: (String? value) {
          if (value != null) {
            inventarioProvider.setFormularioTandaData('idUbicacion', value);
          }
        },
        selectedOptionBuilder: (context, value) {
          for (var ubicacion in lista) {
            if (ubicacion.id == value) {
              return Row(
                children: [
                  const Icon(MdiIcons.pinOutline),
                  Text(ubicacion.descripcion),
                ],
              );
            }
          }
          return const Text('Selecciona una opción');
        },
      ),
    );
  }
}

class HeadRowTextForm extends StatelessWidget {
  const HeadRowTextForm({
    super.key,
    required this.texto,
    required this.funcionOnPressed,
  });

  final String texto;
  final Function() funcionOnPressed;
  @override
  Widget build(BuildContext context) {
    final textStyles = ShadTheme.of(context).textTheme;
    final colors = ShadTheme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(
            texto,
            style: textStyles.small,
          ),
          const Spacer(),
          SizedBox(
            width: 35,
            height: 35,
            child: ShadButton(
              size: ShadButtonSize.sm,
              icon: Icon(
                Icons.add,
                size: 18,
                color: colors.primary,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class HeadTextForm extends StatelessWidget {
  const HeadTextForm({super.key, required this.texto});
  final String texto;
  @override
  Widget build(BuildContext context) {
    final colors = ShadTheme.of(context).colorScheme;
    final textStyles = ShadTheme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        texto,
        style: textStyles.small,
      ),
    );
  }
}

class SelectSearch extends StatefulWidget {
  const SelectSearch({super.key, required this.productosSelection});

  final Map<String, SelectionProductModel> productosSelection;

  @override
  State<SelectSearch> createState() => _SelectSearchState();
}

class _SelectSearchState extends State<SelectSearch> {
  var searchValue = '';

  Map<String, dynamic> get filteredProducto => {
        for (final producto in widget.productosSelection.entries)
          if (producto.value.nombre
              .toLowerCase()
              .contains(searchValue.toLowerCase()))
            producto.key: producto.value
      };

  @override
  Widget build(BuildContext context) {
    final inventarioProvider = context.watch<InventarioProvider>();
    return FadeInLeft(
      duration: const Duration(milliseconds: 200),
      child: ShadSelect<String>.withSearch(
        minWidth: 180,
        placeholder: const Text('Seleccionar producto...'),
        onSearchChanged: (value) => setState(() {
          searchValue = value;
        }),
        searchPlaceholder: const Text('Buscar producto'),
        options: [
          if (filteredProducto.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('No se encuentran productos...'),
            ),
          ...widget.productosSelection.entries.map(
            (producto) {
              return Offstage(
                offstage: !filteredProducto.containsKey(producto.key),
                child: ShadOption(
                  value: producto.key,
                  child: Text(producto.value.nombre),
                ),
              );
            },
          )
        ],
        onChanged: (String? value) {
          if (value != null) {
            final producto = widget.productosSelection[value]!;
            // Actualiza inventarioProvider al seleccionar una opción, fuera de la fase de construcción
            inventarioProvider.setFormularioTandaData(
                'idProducto', producto.id);
            inventarioProvider.setFormularioTandaData(
                'idCategoria', producto.categoria.id);
          }
        },
        selectedOptionBuilder: (context, value) {
          final producto = widget.productosSelection[value]!;
          return Text(producto.nombre);
        },
      ),
    );
  }
}

class BotonAgregar extends StatelessWidget {
  const BotonAgregar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final inventarioProvider = context.watch<InventarioProvider>();

    return Positioned(
      bottom: 10.0,
      left: 10.0,
      right: 10.0,
      child: ShadButton(
        child: const Text('Añadir'),
        onPressed: () {
          print(inventarioProvider.formularioTandaData);
        },
      ),
    );
  }
}
