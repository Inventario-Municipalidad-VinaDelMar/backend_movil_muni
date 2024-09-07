import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/infraestructure/models/bodegas_model.dart';
import 'package:frontend_movil_muni/infraestructure/models/producto_model.dart';
import 'package:frontend_movil_muni/src/providers/inventario/inventario_provider.dart';
import 'package:frontend_movil_muni/src/providers/inventario/mixin/socket/socket_inventario_provider.dart';
import 'package:frontend_movil_muni/src/utils/dateText.dart';
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
  late Map<String, SelectionProductModel> productosSelection;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventarioProvider = context.watch<InventarioProvider>();
    ShadPopoverController bodegaController = ShadPopoverController();
    if (inventarioProvider.loadingProductos &
        inventarioProvider.loadingBodegas) {
      return Center(child: CircularProgressIndicator());
    }
    productosSelection =
        mapearListaAProductoMap(inventarioProvider.productosSelection);
    print("Bodegas ${inventarioProvider.bodegas}");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Tanda'),
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              HeadRowTextForm(
                texto: 'Producto:',
                funcionOnPressed: () {},
              ),
              SelectSearch(
                productosSelection: productosSelection,
              ),
              HeadTextForm(
                texto: 'Cantidad: ',
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: const ShadInput(
                  placeholder: Text('200...'),
                  keyboardType: TextInputType.number,
                ),
              ),
              HeadTextForm(
                texto: 'Fecha de vencimiento: ',
              ),
              CustomDateInput(
                label: 'Fecha de vencimiento...',
                validator: (String? errorsDate) {
                  setState(() {
                    isInvalidDate = errorsDate != null;
                  });
                },
                controller: fechaController,
              ),
              HeadTextForm(
                texto: 'Bodega: ',
              ),
              SelectListBodega(
                lista: inventarioProvider.bodegas,
                nombre: 'Bodega',
                controller: bodegaController,
              ),
              HeadRowTextForm(
                texto: 'Ubicación: ',
                funcionOnPressed: () {},
              ),
              // SelectSearch(),
            ],
          ),
          BotonAgregar()
        ],
      ),
    );
  }
}

class SelectListBodega extends StatelessWidget {
  const SelectListBodega({
    super.key,
    required this.lista,
    required this.nombre,
    required this.controller,
  });
  final List<BodegaModel> lista;
  final String nombre;
  final ShadPopoverController controller;
  @override
  Widget build(BuildContext context) {
    final textStyles = ShadTheme.of(context).textTheme;
    final colors = ShadTheme.of(context).colorScheme;
    return ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 180),
        child: ShadSelect<String>(
            initialValue: lista[0].id,
            controller: controller,
            placeholder: Text('Selecciona un ${nombre}: '),
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
              ...lista
                  .map((e) => ShadOption(
                      value: e.id, child: Text("${e.nombre} - ${e.direccion}")))
                  .toList(),
            ],
            selectedOptionBuilder: (context, value) {
              for (var bodega in lista) {
                if (bodega.id == value) {
                  return Row(
                    children: [
                      Icon(Icons.pin_drop_outlined),
                      Text("${bodega.nombre} - ${bodega.direccion}"),
                    ],
                  );
                }
              }
              return Text('Selecciona una opción');
            }));
  }
}

class SelectListUbicacion extends StatelessWidget {
  const SelectListUbicacion({
    super.key,
    required this.lista,
    required this.nombre,
    required this.controller,
  });
  final List<BodegaModel> lista;
  final String nombre;
  final ShadPopoverController controller;
  @override
  Widget build(BuildContext context) {
    final textStyles = ShadTheme.of(context).textTheme;
    final colors = ShadTheme.of(context).colorScheme;
    return ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 180),
        child: ShadSelect<String>(
            initialValue: lista[0].id,
            controller: controller,
            placeholder: Text('Selecciona un ${nombre}: '),
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
              ...lista
                  .map((e) => ShadOption(
                      value: e.id, child: Text("${e.nombre} - ${e.direccion}")))
                  .toList(),
            ],
            selectedOptionBuilder: (context, value) {
              for (var bodega in lista) {
                if (bodega.id == value) {
                  return Row(
                    children: [
                      Icon(Icons.pin_drop_outlined),
                      Text("${bodega.nombre} - ${bodega.direccion}"),
                    ],
                  );
                }
              }
              return Text('Selecciona una opción');
            }));
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

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(
            texto,
            style: textStyles.small,
          ),
          const Spacer(),
          ShadButton(
            size: ShadButtonSize.sm,
            icon: const Icon(
              Icons.add,
            ),
            onPressed: () {},
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
    return ShadSelect<String>.withSearch(
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
              // this offstage is used to avoid the focus loss when the search results appear again
              // because it keeps the widget in the tree.
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
        selectedOptionBuilder: (context, value) {
          print(
              "value is : ${widget.productosSelection[value]!.categoria.nombre}");
          return Text(widget.productosSelection[value]!.nombre ?? "");
        });
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
        child: Text('Añadir'),
        onPressed: () {
          print('Productos: ');
          print(inventarioProvider.productosSelection);
        },
      ),
    );
  }
}
