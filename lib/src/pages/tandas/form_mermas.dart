import 'package:animate_do/animate_do.dart';
import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/infraestructure/models/inventario/producto_model.dart';
import 'package:frontend_movil_muni/infraestructure/models/inventario/tanda_model.dart';
import 'package:frontend_movil_muni/src/providers/inventario/inventario_provider.dart';
import 'package:frontend_movil_muni/src/providers/inventario/mixin/socket/socket_inventario_provider.dart';
import 'package:frontend_movil_muni/src/providers/movimientos/movimiento_provider.dart';
import 'package:frontend_movil_muni/src/utils/dates_utils.dart';
import 'package:frontend_movil_muni/src/widgets/confirmation_dialog.dart';
import 'package:frontend_movil_muni/src/widgets/generic_select_input.dart';
import 'package:frontend_movil_muni/src/widgets/generic_text_input.dart';
import 'package:frontend_movil_muni/src/widgets/sound/sound_player.dart';
import 'package:frontend_movil_muni/src/widgets/toast/toast_shad.dart';
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
    super.initState();
    _inventarioProvider = context.read<InventarioProvider>();
    _inventarioProvider.connect(
      [InventarioEvent.getProductos],
    );
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
    final movimientoProvider = context.watch<MovimientoProvider>();
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
          child: inventarioProvider.loadingProductos
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : ShadForm(
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
                              final producto = inventarioProvider
                                  .productosSelection
                                  .firstWhere(
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
                                (t) =>
                                    '${t.bodega} --> ${t.ubicacion}' == value,
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
                              if (tandaSelected == null) {
                                return null;
                              }
                              if (int.parse(value) >
                                  tandaSelected!.cantidadActual) {
                                return 'La cantidad no pueder ser superior a "${tandaSelected!.cantidadActual}".';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(
                          height: size.height * 0.1,
                        ),
                        ShadButton(
                          enabled: !movimientoProvider.creatingMerma,
                          width: size.width,
                          onPressed: () async {
                            if (movimientoProvider.creatingMerma) {
                              return;
                            }
                            if (!formKey.currentState!.saveAndValidate()) {
                              return;
                            }
                            if (tandaSelected == null ||
                                productoSelected == null) {
                              return;
                            }

                            final mermaData = {
                              'idTanda': tandaSelected!.id,
                              'idProducto': productoSelected!.id,
                              'comentario': formKey
                                  .currentState?.fields['comentario']!.value,
                              'cantidadMerma': int.parse(
                                formKey.currentState?.fields['cantidad']!.value,
                              ),
                            };
                            await showAlertDialog(
                              context: context,
                              description:
                                  'Esta accion registrará una merma en el sistema. Se descontará stock del inventario.',
                              continueFunction: () async {
                                try {
                                  await movimientoProvider
                                      .addNewMerma(mermaData);
                                  if (!context.mounted) {
                                    return;
                                  }
                                  SoundPlayer.playSound('positive.wav');

                                  throwToastSuccess(
                                    context: context,
                                    title: 'Merma registrada',
                                    descripcion:
                                        'La merma fue registrada en el sistema.',
                                  );

                                  context.pop();
                                } catch (e) {
                                  if (!context.mounted) {
                                    return;
                                  }
                                  SoundPlayer.playSound('negative.wav');
                                  throwToastError(
                                    context: context,
                                    descripcion: 'Ocurrio un error',
                                  );
                                }
                              },
                            ).then((_) {
                              if (!context.mounted) {
                                return;
                              }
                              FocusScope.of(context).unfocus();
                            });
                          },
                          size: ShadButtonSize.lg,
                          child: movimientoProvider.creatingMerma
                              ? ZoomIn(
                                  duration: Duration(milliseconds: 300),
                                  child: Row(
                                    children: [
                                      AnimateIcon(
                                        color: Colors.white,
                                        onTap: () {},
                                        width: size.height * 0.04,
                                        height: size.height * 0.04,
                                        iconType: IconType.continueAnimation,
                                        animateIcon: AnimateIcons.loading6,
                                      ),
                                      SizedBox(width: size.width * 0.02),
                                      Text('Registrando merma'),
                                    ],
                                  ),
                                )
                              : FadeIn(
                                  duration: Duration(milliseconds: 200),
                                  child: Text('Ingresar merma'),
                                ),
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
