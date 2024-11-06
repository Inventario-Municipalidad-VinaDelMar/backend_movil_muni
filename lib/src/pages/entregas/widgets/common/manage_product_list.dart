import 'package:animate_do/animate_do.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:frontend_movil_muni/infraestructure/models/logistica/envio_logistico_model.dart';
import 'package:frontend_movil_muni/src/pages/entregas/widgets/common/dialog_set_producto.dart';
import 'package:frontend_movil_muni/src/providers/provider.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ManageProductList extends StatefulWidget {
  final List<ProductoEnvio> items;
  final String idEnvio;
  final String labelText;
  final ScrollController scrollSingleChild;
  final bool isDelivery; //Entrega o incidente
  final EdgeInsetsGeometry? padding;
  const ManageProductList({
    super.key,
    required this.items,
    required this.idEnvio,
    required this.isDelivery,
    required this.scrollSingleChild,
    required this.labelText,
    this.padding,
  });

  @override
  State<ManageProductList> createState() => _ManageProductListState();
}

class _ManageProductListState extends State<ManageProductList> {
  final ScrollController scrollList = ScrollController();
  late EntregaProvider _entregaProvider;
  late EnvioProvider _envioProvider;

  @override
  void initState() {
    super.initState();
    _entregaProvider = context.read<EntregaProvider>();
    _envioProvider = context.read<EnvioProvider>();
    List<ProductoEnvio> items = [];
    if (widget.isDelivery) {
      items = _entregaProvider.getProductosPorEnvioEntrega(widget.idEnvio);
    } else {
      items = _envioProvider.getProductosPorEnvioIncidente(widget.idEnvio);
    }
    scrollToBottomSingleChild(items: items, delivering: widget.isDelivery);
  }

  Future<void> scrollToBottomSingleChild({
    bool addedProduct = false,
    required List<ProductoEnvio> items,
    bool delivering = true,
  }) async {
    if (items.isEmpty && !addedProduct) {
      return;
    }
    int delay = 0;
    if (delivering) {
      delay = 1400;
    } else {
      delay = 300;
    }
    if (addedProduct) {
      delay = 100;
    }
    await Future.delayed(Duration(milliseconds: delay));
    widget.scrollSingleChild.animateTo(
      widget.scrollSingleChild.position
          .maxScrollExtent, // Posición máxima de scroll
      duration: Duration(milliseconds: 400), // Duración de la animación
      curve: Curves.easeOut, // Curva de la animación
    );
  }

  void executeAddProduct(
    Size size,
    EnvioLogisticoModel envio,
    ShadTextTheme textStyles,
    List<ProductoEnvio> items,
  ) {
    int indexSelected = 0;
    final formKey = GlobalKey<ShadFormState>();
    final List<ProductoEnvio> productos = List.from(envio.productos);

    productos.removeWhere((producto) => items
        .any((modificado) => modificado.productoId == producto.productoId));

    ProductoEnvio cargaSelected = productos[0];

    showShadDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return DialogSetProducto(
            isDelivey: widget.isDelivery,
            cargaSelected: cargaSelected,
            indexSelected: indexSelected,
            formKey: formKey,
            idEnvio: widget.idEnvio,
            onTap: (i, carga) {
              setState(() {
                indexSelected = i;
                cargaSelected = carga;
              });
            },
            productos: productos,
          );
        },
      ),
    ).then((value) async {
      if (context.mounted) {
        FocusScope.of(context).unfocus();
      }

      await Future.delayed(Duration(milliseconds: 200));
      // scrollToBottom();
      scrollToBottomSingleChild(addedProduct: true, items: items);
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final textStyles = ShadTheme.of(context).textTheme;
    final entregaProvider = context.watch<EntregaProvider>();
    final envioProvider = context.watch<EnvioProvider>();
    final envio = context.watch<EnvioProvider>().findEnvioById(widget.idEnvio);
    return Padding(
      padding: widget.padding ?? EdgeInsets.all(0),
      child: Column(
        children: [
          ZoomIn(
            duration: Duration(milliseconds: 200),
            delay: Duration(milliseconds: 100),
            child: Row(
              children: [
                Text(
                  widget.labelText,
                  // 'Registrar productos entregados',
                  style: textStyles.p.copyWith(
                      // fontWeight: FontWeight.bold,
                      ),
                ),
                Spacer(),
                if (widget.items.isNotEmpty &&
                    widget.items.length < envio!.productos.length)
                  ShadButton(
                    height: size.height * 0.035,
                    width: size.height * 0.035,
                    padding: EdgeInsets.all(0),
                    size: ShadButtonSize.sm,
                    onPressed: () {
                      executeAddProduct(
                        size,
                        envio,
                        textStyles,
                        widget.items,
                      );
                    },
                    icon: Icon(
                      Icons.add,
                      size: 24,
                    ),
                  )
              ],
            ),
          ),
          SizedBox(height: size.height * 0.01),
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: double.infinity,
            // height: widget.items.isEmpty
            //     ? null
            //     : widget.items.length < 4
            //         ? heightCustom * widget.items.length
            //         : size.height * 0.31,
            child: widget.items.isEmpty
                ? FadeInRight(
                    duration: Duration(milliseconds: 200),
                    delay: Duration(milliseconds: 200),
                    child: DottedBorder(
                      color: Colors.blue.withOpacity(.7),
                      dashPattern: const [4.5, 4.5, 4.5, 4.5],
                      borderType: BorderType.RRect,
                      radius: Radius.circular(12),
                      padding: EdgeInsets.all(6),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        child: Container(
                          height: size.height * 0.07,
                          width: double.infinity,
                          color: Colors.blue[500]!.withOpacity(.2),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ShadButton(
                                onPressed: () => executeAddProduct(
                                    size, envio!, textStyles, widget.items),
                                backgroundColor: Colors.blueAccent,
                                size: ShadButtonSize.sm,
                                icon: Icon(
                                  Icons.add,
                                  size: 20,
                                ),
                                child: Text(
                                  'Registrar',
                                  style: textStyles.small.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    controller: scrollList,
                    // padding: const EdgeInsets.symmetric(horizontal: 25),
                    physics: BouncingScrollPhysics(),
                    itemCount: widget.items.length,
                    itemBuilder: (context, i) {
                      //Carga afectada o carga entregada
                      final carga = widget.items[i];
                      return Dismissible(
                        key: ValueKey(carga.productoId),
                        direction: DismissDirection.startToEnd,
                        onDismissed: (direction) {
                          setState(() {
                            if (widget.isDelivery) {
                              entregaProvider.removeOneProduct(
                                widget.idEnvio,
                                carga,
                              );
                              return;
                            }
                            envioProvider.removeOneProduct(
                              widget.idEnvio,
                              carga,
                            );
                            // eliminarProducto(carga);
                          });
                        },
                        child: FadeInRight(
                          duration: Duration(milliseconds: 200),
                          delay: Duration(milliseconds: 100),
                          child: Container(
                            padding: EdgeInsets.only(left: 0, right: 10),
                            margin: EdgeInsets.only(bottom: 5),
                            height: size.height * 0.07,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white70,
                              // color: Colors.blue[500]!.withOpacity(.2),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  offset: Offset(2, 4),
                                  blurRadius: 15,
                                  spreadRadius: -3,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: double.infinity,
                                  width: size.width * 0.12,
                                  decoration: BoxDecoration(
                                    color: widget.isDelivery
                                        ? Colors.green[500]
                                        : Colors.red[500],
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomLeft: Radius.circular(12),
                                    ),
                                  ),
                                  child: Icon(
                                    widget.isDelivery
                                        ? MdiIcons.checkDecagramOutline
                                        : MdiIcons.busAlert,
                                    color: Colors.white,
                                    size: size.height * 0.038,
                                  ),
                                ),
                                SizedBox(width: size.width * 0.03),
                                ShadAvatar(
                                  carga.urlImagen,
                                  fit: BoxFit.contain,
                                  backgroundColor: Colors.white,
                                  size: Size(
                                    size.height * 0.06,
                                    size.height * 0.06,
                                  ), // Tamaño del avatar
                                ),
                                SizedBox(
                                  width: size.width * 0.03,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  width: size.width * 0.4,
                                  child: Wrap(
                                    children: [
                                      Text(
                                        carga.producto,
                                        softWrap: true,
                                        style: textStyles.small
                                            .copyWith(height: 1.2),
                                      )
                                    ],
                                  ),
                                ),
                                Spacer(),
                                ShadBadge(
                                  backgroundColor: widget.isDelivery
                                      ? Colors.blue[500]
                                      : Colors.orange[500],
                                  child: Text(
                                    '${carga.cantidad}',
                                    style: textStyles.small.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
