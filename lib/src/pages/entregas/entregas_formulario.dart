import 'package:animate_do/animate_do.dart';
import 'package:animated_icon/animated_icon.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:frontend_movil_muni/infraestructure/models/logistica/comedor_solidario_model.dart';
import 'package:frontend_movil_muni/infraestructure/models/logistica/envio_logistico_model.dart';
import 'package:frontend_movil_muni/src/pages/entregas/widgets/entregas_formulario/dialog_set_producto.dart';
import 'package:frontend_movil_muni/src/providers/logistica/entregas/socket/socket_entrega_provider.dart';
import 'package:frontend_movil_muni/src/providers/provider.dart';
import 'package:frontend_movil_muni/src/widgets/generic_select_input.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class EntregasFormulario extends StatefulWidget {
  final String idEnvio;
  const EntregasFormulario({
    super.key,
    required this.idEnvio,
  });

  @override
  State<EntregasFormulario> createState() => _EntregasFormularioState();
}

class _EntregasFormularioState extends State<EntregasFormulario> {
  final formEntrega = GlobalKey<ShadFormState>();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollRutaActual = ScrollController();
  final ScrollController _scrollSingleChild = ScrollController();
  late EntregaProvider _entregaProvider;
  @override
  void initState() {
    _entregaProvider = context.read<EntregaProvider>();
    _entregaProvider.connect(
      [
        EntregaEvent.comedoresSolidarios,
      ],
    );
    scrollToMaxRight();
    scrollToBottomSingleChild();
    super.initState();
  }

  @override
  void dispose() {
    _entregaProvider.disconnect(
      [
        EntregaEvent.comedoresSolidarios,
      ],
    );
    super.dispose();
  }

  void scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent, // Posición máxima de scroll
      duration: Duration(milliseconds: 450), // Duración de la animación
      curve: Curves.easeOut, // Curva de la animación
    );
  }

  Future<void> scrollToMaxRight() async {
    await Future.delayed(Duration(milliseconds: 200));
    _scrollRutaActual.animateTo(
      _scrollRutaActual.position.maxScrollExtent -
          22, // Posición máxima de scroll
      duration: Duration(milliseconds: 1250), // Duración de la animación
      curve: Curves.easeOut, // Curva de la animación
    );
  }

  Future<void> scrollToBottomSingleChild({bool addedProduct = false}) async {
    final productoEntregados =
        _entregaProvider.getProductosPorEnvio(widget.idEnvio);
    if (productoEntregados.isEmpty) {
      return;
    }
    int delay = 1400;
    if (addedProduct) {
      delay = 300;
    }
    await Future.delayed(Duration(milliseconds: delay));
    _scrollSingleChild.animateTo(
      _scrollSingleChild.position.maxScrollExtent -
          22, // Posición máxima de scroll
      duration: Duration(milliseconds: 400), // Duración de la animación
      curve: Curves.easeOut, // Curva de la animación
    );
  }

  void executeAddProduct(
      Size size, EnvioLogisticoModel envio, ShadTextTheme textStyles) {
    int indexSelected = 0;
    final formKey = GlobalKey<ShadFormState>();
    final productoEntregados =
        _entregaProvider.getProductosPorEnvio(widget.idEnvio);
    final List<ProductoEnvio> productos = List.from(envio.productos);
    // Filtramos los productos eliminando aquellos cuyos IDs están en productoEntregados
    productos.removeWhere((producto) => productoEntregados
        .any((entregado) => entregado.productoId == producto.productoId));
    ProductoEnvio cargaSelected = productos[0];

    showShadDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return DialogSetProducto(
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
      await Future.delayed(Duration(milliseconds: 200));
      // scrollToBottom();
      scrollToBottomSingleChild(addedProduct: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final envio = context.watch<EnvioProvider>().findEnvioById(widget.idEnvio);
    final productosEntregados =
        context.watch<EntregaProvider>().getProductosPorEnvio(widget.idEnvio);
    if (envio == null) {
      context.pop();
    }
    final entregasProvider = context.watch<EntregaProvider>();
    Size size = MediaQuery.of(context).size;
    final textStyles = ShadTheme.of(context).textTheme;
    return Scaffold(
      backgroundColor:
          Colors.grey[200], // Cambiamos el fondo a un color más suave
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue[600],
        title: Text(
          'Nueva entrega',
          style: textStyles.h4.copyWith(
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Visibility(
        visible: productosEntregados.isNotEmpty &&
            MediaQuery.of(context).viewInsets.bottom == 0,
        child: FadeInUp(
          duration: Duration(milliseconds: 200),
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
            child: ShadButton(
              enabled: !entregasProvider.creatingEntrega,
              onPressed: () async {
                if (!formEntrega.currentState!.saveAndValidate()) {
                  return;
                }
                final idComedor = entregasProvider.findIdComedorSolidario(
                    formEntrega.currentState?.fields['comedor']!.value);
                if (idComedor.isEmpty) {
                  return;
                }
                await entregasProvider.generateNewEntrega(
                  {
                    'idEnvio': widget.idEnvio,
                    'idComedor': idComedor,
                    'detalles': List.from(productosEntregados.map((p) {
                      return {
                        'productoId': p.productoId,
                        'cantidadEntregada': p.cantidad,
                      };
                    }).toList()),
                  },
                  widget.idEnvio,
                ).then((value) {
                  if (!context.mounted) {
                    return;
                  }
                  context.pop();
                });
              },
              width: size.width,
              size: ShadButtonSize.lg,
              icon: entregasProvider.creatingEntrega
                  ? SizedBox(
                      width: size.height * 0.03,
                      height: size.height * 0.03,
                      child: AnimateIcon(
                        animateIcon: AnimateIcons.loading6,
                        color: Colors.white,
                        iconType: IconType.continueAnimation,
                        onTap: () {},
                      ),
                    )
                  : null,
              child: entregasProvider.creatingEntrega
                  ? Text('Creando entrega',
                      style: textStyles.h4.copyWith(
                        color: Colors.white,
                      ))
                  : Text(
                      'Ingresar entrega',
                      style: textStyles.h4.copyWith(
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollSingleChild,
        child: ShadForm(
          key: formEntrega,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: Text(
                  'Ruta actual',
                  style: textStyles.p,
                ),
              ),
              if (envio!.entregas.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: SizedBox(
                    width: double.infinity,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        SizedBox(
                          width: size.width * 0.4,
                          child: FadeIn(
                            duration: Duration(milliseconds: 200),
                            child: Column(
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  alignment: Alignment.center,
                                  children: [
                                    Positioned(
                                      top: -size.height * 0.014,
                                      left: -size.width * 0.1,
                                      child: ZoomIn(
                                        duration: Duration(milliseconds: 500),
                                        child: Icon(
                                          Icons.arrow_right_alt_rounded,
                                          color: Colors.blue,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: -size.width * 0.155,
                                      child: AnimatedContainer(
                                        duration: Duration(milliseconds: 200),
                                        height: 5,
                                        width: size.width * 0.155,
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                    AnimatedContainer(
                                      duration: Duration(milliseconds: 200),
                                      height: size.height * 0.045,
                                      width: size.height * 0.045,
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(.7),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        MdiIcons.downloadBox,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Positioned(
                                      // top: 0,
                                      right: -size.width * 0.22,
                                      child: SizedBox(
                                        // width: size.height * 0.02,
                                        height: size.height * 0.02,
                                        child: Text(
                                          'Primera entrega',
                                          style: textStyles.small.copyWith(
                                            color: Colors.blue.withOpacity(.7),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: size.height * 0.008,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (envio.entregas.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(top: 5),
                  width: size.width,
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  height: size.height * 0.085,
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    controller: _scrollRutaActual,
                    scrollDirection: Axis.horizontal,
                    itemCount: envio.entregas.length + 1,
                    itemBuilder: (context, i) {
                      EntregaEnvio? entrega;
                      bool isLast = i == envio.entregas.length;
                      if (!isLast) {
                        entrega = envio.entregas[i];
                      }
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: size.width * 0.2,
                            margin: EdgeInsets.only(right: size.width * 0.045),
                            child: FadeIn(
                              duration: Duration(milliseconds: 200),
                              delay: Duration(milliseconds: i * 150),
                              child: Column(
                                children: [
                                  Stack(
                                    clipBehavior: Clip.none,
                                    alignment: Alignment.center,
                                    children: [
                                      Positioned(
                                        left: -size.width * 0.155,
                                        child: AnimatedContainer(
                                          duration: Duration(milliseconds: 200),
                                          height: 5,
                                          width:
                                              isLast ? 0 : size.width * 0.155,
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                      AnimatedContainer(
                                        duration: Duration(milliseconds: 200),
                                        height: size.height * 0.045,
                                        width: size.height * 0.045,
                                        decoration: BoxDecoration(
                                          color: isLast
                                              ? Colors.blue.withOpacity(.5)
                                              : Colors.blue,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          isLast
                                              ? MdiIcons.downloadBox
                                              : MdiIcons.mapMarker,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Positioned(
                                        right: -size.width * 0.155,
                                        child: AnimatedContainer(
                                          duration: Duration(milliseconds: 200),
                                          height: 5,
                                          width:
                                              isLast ? 0 : size.width * 0.155,
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: size.height * 0.008,
                                  ),
                                  if (!isLast)
                                    Text(
                                      entrega!.comedorSolidario,
                                      style: textStyles.small.copyWith(
                                        height: 1,
                                        fontSize: size.height * 0.015,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  if (isLast)
                                    // Icon(
                                    //   MdiIcons.menuUp,
                                    //   color: Colors.blue.withOpacity(.8),
                                    //   size: 24,
                                    // ),
                                    SizedBox(
                                      width: size.height * 0.02,
                                      height: size.height * 0.02,
                                      child: AnimateIcon(
                                        onTap: () {},
                                        iconType: IconType.continueAnimation,
                                        animateIcon: AnimateIcons.loading4,
                                        color: Colors.blue,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          if (!isLast)
                            Positioned(
                              top: -size.height * 0.014,
                              right: -size.width * 0.033,
                              child: ZoomIn(
                                duration: Duration(milliseconds: 500),
                                delay: Duration(microseconds: i * 150),
                                child: Icon(
                                  Icons.arrow_right_alt_rounded,
                                  color: Colors.blue,
                                  size: 30,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              if (!entregasProvider.loadingEntregas)
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: GenericSelectInput<ComedorSolidarioModel>(
                    padding: 40,
                    errorText: 'Por favor, selecciona un comedor solidario',
                    items: entregasProvider.comedores,
                    displayField: (comedor) => comedor.nombre,
                    labelText: 'Comedor solidario',
                    fieldId: 'comedor',
                    placeholderText: 'Seleccionar comedor...',
                  ),
                ),
              SizedBox(
                height: size.height * 0.01,
              ),
              _InfoEnvioPreview(
                envio: envio!,
              ),
              SizedBox(
                height: size.height * 0.02,
              ),
              ZoomIn(
                duration: Duration(milliseconds: 200),
                delay: Duration(milliseconds: 100),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    children: [
                      Text(
                        'Registrar productos entregados',
                        style: textStyles.p.copyWith(
                            // fontWeight: FontWeight.bold,
                            ),
                      ),
                      Spacer(),
                      if (productosEntregados.isNotEmpty &&
                          productosEntregados.length < envio.productos.length)
                        ShadButton(
                          height: size.height * 0.035,
                          width: size.height * 0.035,
                          padding: EdgeInsets.all(0),
                          size: ShadButtonSize.sm,
                          onPressed: () {
                            executeAddProduct(size, envio, textStyles);
                          },
                          icon: Icon(
                            Icons.add,
                            size: 24,
                          ),
                        )
                    ],
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.01),
              SizedBox(
                width: double.infinity,
                height: productosEntregados.isEmpty ? null : size.height * 0.31,
                child: productosEntregados.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: FadeInRight(
                          duration: Duration(milliseconds: 200),
                          delay: Duration(milliseconds: 200),
                          child: DottedBorder(
                            color: Colors.blue.withOpacity(.7),
                            dashPattern: const [4.5, 4.5, 4.5, 4.5],
                            borderType: BorderType.RRect,
                            radius: Radius.circular(12),
                            padding: EdgeInsets.all(6),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                              child: Container(
                                height: size.height * 0.07,
                                width: double.infinity,
                                color: Colors.blue[500]!.withOpacity(.2),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ShadButton(
                                      onPressed: () => executeAddProduct(
                                        size,
                                        envio,
                                        textStyles,
                                      ),
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
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        physics: BouncingScrollPhysics(),
                        itemCount: productosEntregados.length,
                        itemBuilder: (context, i) {
                          final cargaEntregada = productosEntregados[i];
                          return Dismissible(
                            key: ValueKey(cargaEntregada.productoId),
                            direction: DismissDirection.startToEnd,
                            onDismissed: (direction) {
                              setState(() {
                                entregasProvider.removeOneProduct(
                                    widget.idEnvio, cargaEntregada);
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
                                        color: Colors.green[500],
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          bottomLeft: Radius.circular(12),
                                        ),
                                      ),
                                      child: Icon(
                                        MdiIcons.checkDecagramOutline,
                                        color: Colors.white,
                                        size: size.height * 0.038,
                                      ),
                                    ),
                                    SizedBox(width: size.width * 0.03),
                                    ShadAvatar(
                                      cargaEntregada.urlImagen,
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
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5),
                                      width: size.width * 0.4,
                                      child: Wrap(
                                        children: [
                                          Text(
                                            cargaEntregada.producto,
                                            softWrap: true,
                                            style: textStyles.small
                                                .copyWith(height: 1.2),
                                          )
                                        ],
                                      ),
                                    ),
                                    Spacer(),
                                    ShadBadge(
                                      backgroundColor: Colors.blue[500],
                                      child: Text(
                                        '${cargaEntregada.cantidad}',
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
              SizedBox(height: size.height * 0.14),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoEnvioPreview extends StatelessWidget {
  const _InfoEnvioPreview({
    required this.envio,
  });

  final EnvioLogisticoModel envio;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final textStyles = ShadTheme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(
        left: 25,
        right: 25,
        top: 15,
      ),
      child: SizedBox(
        width: size.width,
        height: size.height * 0.3,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  padding: EdgeInsets.only(
                    left: 10,
                    right: 10,
                    // bottom: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[500]!.withOpacity(.7),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  width: double.infinity,
                  height: size.height * 0.07,
                  child: Row(
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: size.height * 0.04,
                        backgroundImage:
                            const AssetImage('assets/logos/camiones3.gif'),
                      ),
                      SizedBox(width: size.width * 0.04),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Cargamento actual',
                            style: textStyles.p.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: size.height * 0.0095)
                        ],
                      ),
                      Spacer(),
                      Icon(
                        MdiIcons.mapMarkerDistance,
                        color: Colors.white,
                        size: 35,
                      ),
                      SizedBox(
                        width: size.width * 0.05,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  // right: size.width * 0.04,
                  top: -(size.height * 0.01),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      envio.statusToString(),
                      style: textStyles.small.copyWith(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.all(10),
                  itemCount: envio.productos.length,
                  itemBuilder: (context, i) {
                    final carga = envio.productos[i];
                    return Column(
                      children: [
                        Container(
                          // color: Colors.red,
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          // margin: EdgeInsets.only(bottom: 5),
                          width: double.infinity,
                          height: size.height * 0.05,
                          child: Row(
                            children: [
                              ShadAvatar(
                                carga.urlImagen,
                                fit: BoxFit.contain,
                                backgroundColor: Colors.transparent,
                                size: Size(
                                  size.height * 0.045,
                                  size.height * 0.045,
                                ), // Tamaño del avatar
                              ),
                              SizedBox(width: size.width * 0.03),
                              SizedBox(
                                // height: double.infinity,
                                width: size.width * 0.5,
                                child: Wrap(
                                  children: [
                                    Text(
                                      carga.producto,
                                      style: textStyles.p.copyWith(height: 1.2),
                                      softWrap: true,
                                    ),
                                  ],
                                ),
                              ),
                              Spacer(),
                              ShadBadge(
                                child: Text('${carga.cantidad}'),
                              )
                            ],
                          ),
                        ),
                        if (i < envio.productos.length - 1) Divider(),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
