import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/infraestructure/models/inventario/producto_model.dart';
import 'package:frontend_movil_muni/infraestructure/models/inventario/tanda_model.dart';
import 'package:frontend_movil_muni/src/providers/inventario/inventario_provider.dart';
import 'package:frontend_movil_muni/src/providers/inventario/mixin/socket/socket_inventario_provider.dart';
import 'package:frontend_movil_muni/src/utils/dates_utils.dart';
import 'package:frontend_movil_muni/src/widgets/generic_select_input.dart';
import 'package:frontend_movil_muni/src/widgets/generic_text_input.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class FormMermas extends StatefulWidget {
  const FormMermas({super.key});

  @override
  State<FormMermas> createState() => _FormMermasState();
}

class _FormMermasState extends State<FormMermas> {
  late InventarioProvider _inventarioProvider;
  SelectionProductModel? productoSelected;
  TandaModel? tandaSelected;
  TextEditingController controllerComentario = TextEditingController();
  final formKey = GlobalKey<ShadFormState>();
  ScrollController singleChildSc = ScrollController();
  final FocusNode focusComentario = FocusNode();
  @override
  void initState() {
    _inventarioProvider = context.read<InventarioProvider>();
    _inventarioProvider.connect(
      [InventarioEvent.getProductos],
    );
    super.initState();
    focusComentario.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    // Si el campo está enfocado, desplazamos el scroll al fondo
    if (focusComentario.hasFocus) {
      scrollToBottom();
    }
  }

  @override
  void dispose() {
    focusComentario.removeListener(_handleFocusChange);
    focusComentario.dispose();
    controllerComentario.dispose();
    singleChildSc.dispose();
    _inventarioProvider.disconnect(
      [InventarioEvent.getProductos, InventarioEvent.getTandasByProducto],
      productoId: productoSelected?.id,
    );
    super.dispose();
  }

  void getTandas() {
    _inventarioProvider.connect(
      [InventarioEvent.getTandasByProducto],
      productoId: productoSelected?.id,
    );
  }

  Future<void> scrollToBottom() async {
    int delay = 700;
    await Future.delayed(Duration(milliseconds: delay));
    singleChildSc.animateTo(
      singleChildSc.position.maxScrollExtent,
      duration: Duration(milliseconds: 50),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final textStyles = ShadTheme.of(context).textTheme;
    final inventarioProvider = context.watch<InventarioProvider>();
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue[500],
        title: Text(
          'Registrar merma',
          style: textStyles.h4.copyWith(
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: singleChildSc,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
          child: ShadForm(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.02),
                if (!inventarioProvider.loadingProductos)
                  GenericSelectInput<SelectionProductModel>(
                    padding: size.width * 0.1,
                    items: inventarioProvider.productosSelection,
                    displayField: (producto) => producto.nombre,
                    onChanged: (String? value) {
                      if (value != null) {
                        final producto =
                            inventarioProvider.productosSelection.firstWhere(
                          (u) => u.nombre == value,
                          orElse: () => SelectionProductModel.getNull(),
                        );
                        if (producto.id != '') {
                          setState(() {
                            productoSelected = producto;
                          });
                          getTandas();
                        }
                      }
                    },
                    fieldId: 'producto',
                    labelText: 'Producto',
                    placeholderText: 'Seleccionar producto...',
                    searchPlaceholderText: 'Buscar producto',
                  ),
                SizedBox(height: size.height * 0.02),
                if (!inventarioProvider.loadingTandas &&
                    inventarioProvider.tandaByProducto.isNotEmpty)
                  GenericSelectInput<TandaModel>(
                    padding: size.width * 0.1,
                    items: inventarioProvider.tandaByProducto,
                    displayField: (tanda) =>
                        '${tanda.bodega} --> ${tanda.ubicacion}',
                    onChanged: (String? value) {
                      if (value != null) {
                        final tanda =
                            inventarioProvider.tandaByProducto.firstWhere(
                          (t) => '${t.bodega} --> ${t.ubicacion}' == value,
                          orElse: () => TandaModel.getNull(),
                        );
                        if (tanda.id != '') {
                          setState(() {
                            tandaSelected = tanda;
                          });
                        }
                      }
                    },
                    fieldId: 'tanda',
                    labelText: 'Tanda',
                    placeholderText: 'Seleccionar tanda...',
                    searchPlaceholderText: 'Buscar tanda',
                  ),
                SizedBox(height: size.height * 0.02),
                if (tandaSelected != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Datos de esta tanda',
                          style: textStyles.p,
                        ),
                        SizedBox(height: size.height * 0.02),
                        Row(
                          children: [
                            Text(
                              'Cantidad actual',
                              style: textStyles.small.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            Text(
                              '${tandaSelected!.cantidadActual}',
                              style: textStyles.small.copyWith(
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.01),
                        Row(
                          children: [
                            Text(
                              'Cantidad ingresada',
                              style: textStyles.small.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            Text(
                              '${tandaSelected!.cantidadIngresada}',
                              style: textStyles.small.copyWith(
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.01),
                        Row(
                          children: [
                            Text(
                              'Vencimiento en',
                              style: textStyles.small.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            Text(
                              calcularDiasRestantes(
                                  tandaSelected!.fechaVencimiento),
                              style: textStyles.small.copyWith(
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.035,
                  ),
                  GestureDetector(
                    onTap: () {
                      focusComentario
                          .requestFocus(); // Enfoca el campo y abre el teclado
                    },
                    child: GenericTextInput(
                      focusNode: focusComentario,
                      controller: controllerComentario,
                      maxLength: 255,
                      maxLines: 3,
                      placeHolder: 'Indique la situacion de la merma...',
                      id: 'comentario',
                      labelText: 'Comentario',
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'La situacion de la merma debe ser indicada.';
                        }
                        return null;
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () => scrollToBottom(),
                    child: GenericTextInput(
                      placeHolder: '0',
                      id: 'cantidad',
                      labelText: 'Cantidad de merma',
                      inputType: TextInputType.number,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'La cantidad de merma se debe ingresar.';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.1,
                  ),
                  ShadButton(
                    width: size.width,
                    onPressed: () {
                      if (!formKey.currentState!.saveAndValidate()) {
                        return;
                      }
                      context.pop();
                    },
                    size: ShadButtonSize.lg,
                    child: Text('Ingresar merma'),
                  ),
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
