import 'package:animate_do/animate_do.dart';
import 'package:animated_digit/animated_digit.dart';
import 'package:animated_icon/animated_icon.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:frontend_movil_muni/infraestructure/models/logistica/comedor_solidario_model.dart';
import 'package:frontend_movil_muni/infraestructure/models/logistica/envio_logistico_model.dart';
import 'package:frontend_movil_muni/src/pages/entregas/widgets/common/manage_product_list.dart';
import 'package:frontend_movil_muni/src/providers/logistica/entregas/socket/socket_entrega_provider.dart';
import 'package:frontend_movil_muni/src/providers/provider.dart';
import 'package:frontend_movil_muni/src/widgets/confirmation_dialog.dart';
import 'package:frontend_movil_muni/src/widgets/generic_select_input.dart';
import 'package:frontend_movil_muni/src/widgets/sound/sound_player.dart';
import 'package:frontend_movil_muni/src/widgets/toast/toast_shad.dart';
import 'package:frontend_movil_muni/src/widgets/toaster.dart';
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
  // final ScrollController _scrollController = ScrollController();
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

  Future<void> scrollToMaxRight() async {
    await Future.delayed(Duration(milliseconds: 200));
    _scrollRutaActual.animateTo(
      _scrollRutaActual.position.maxScrollExtent -
          22, // Posición máxima de scroll
      duration: Duration(milliseconds: 1250), // Duración de la animación
      curve: Curves.easeOut, // Curva de la animación
    );
  }

  @override
  Widget build(BuildContext context) {
    final envio = context.watch<EnvioProvider>().findEnvioById(widget.idEnvio);
    final productosEntregados = context
        .watch<EntregaProvider>()
        .getProductosPorEnvioEntrega(widget.idEnvio);
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
      body: SingleChildScrollView(
        controller: _scrollSingleChild,
        child: ShadForm(
          key: formEntrega,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ruta actual',
                  style: textStyles.p,
                ),
                if (envio!.entregas.isEmpty) _EmptyRutaActual(),
                if (envio.entregas.isNotEmpty)
                  _RutaActual(
                    scrollRutaActual: _scrollRutaActual,
                    envio: envio,
                  ),
                if (!entregasProvider.loadingEntregas)
                  GenericSelectInput<ComedorSolidarioModel>(
                    padding: 40,
                    errorText: 'Por favor, selecciona un comedor solidario',
                    items: entregasProvider.comedores,
                    displayField: (comedor) => comedor.nombre,
                    labelText: 'Comedor solidario',
                    fieldId: 'comedor',
                    placeholderText: 'Seleccionar comedor...',
                  ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                _InfoEnvioPreview(
                  envio: envio,
                ),
                SizedBox(
                  height: size.height * 0.02,
                ),
                ManageProductList(
                  labelText: 'Registrar productos entregados',
                  items: productosEntregados,
                  idEnvio: widget.idEnvio,
                  isDelivery: true,
                  scrollSingleChild: _scrollSingleChild,
                ),
                SizedBox(
                  // height: size.height * 0.04,
                  height: size.height *
                      0.0775 *
                      ((3 - productosEntregados.length) <= 0
                          ? 0
                          : 3 - productosEntregados.length),
                ),
                _SubmitEntregaButton(
                  productosEntregados: productosEntregados,
                  entregasProvider: entregasProvider,
                  formEntrega: formEntrega,
                  widget: widget,
                ),
                SizedBox(
                  height: size.height * 0.02,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RutaActual extends StatelessWidget {
  const _RutaActual({
    required ScrollController scrollRutaActual,
    required this.envio,
  }) : _scrollRutaActual = scrollRutaActual;

  final ScrollController _scrollRutaActual;
  final EnvioLogisticoModel? envio;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final textStyles = ShadTheme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: ClipRRect(
        child: Container(
          // color: Colors.red,
          margin: EdgeInsets.only(top: 5),
          width: size.width,
          // padding: const EdgeInsets.symmetric(horizontal: 25),
          height: size.height * 0.085,
          child: ListView.builder(
            // padding: const EdgeInsets.symmetric(horizontal: 25),
            physics: BouncingScrollPhysics(),
            controller: _scrollRutaActual,
            scrollDirection: Axis.horizontal,
            itemCount: envio!.entregas.length + 1,
            itemBuilder: (context, i) {
              EntregaEnvio? entrega;
              bool isLast = i == envio!.entregas.length;
              if (!isLast) {
                entrega = envio!.entregas[i];
              }
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: size.width * 0.3,
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
                                left: -size.width * 0.255,
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 200),
                                  height: 5,
                                  width: isLast ? 0 : size.width * 0.255,
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
                                right: -size.width * 0.255,
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 200),
                                  height: 5,
                                  width: isLast ? 0 : size.width * 0.255,
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
                              overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}

class _EmptyRutaActual extends StatelessWidget {
  const _EmptyRutaActual();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final textStyles = ShadTheme.of(context).textTheme;
    return SizedBox(
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
    );
  }
}

class _SubmitEntregaButton extends StatelessWidget {
  _SubmitEntregaButton({
    required this.productosEntregados,
    required this.entregasProvider,
    required this.formEntrega,
    required this.widget,
  });

  final List<ProductoEnvio> productosEntregados;
  final EntregaProvider entregasProvider;
  final GlobalKey<ShadFormState> formEntrega;
  final EntregasFormulario widget;
  final player = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final textStyles = ShadTheme.of(context).textTheme;
    return Visibility(
      visible: productosEntregados.isNotEmpty &&
          MediaQuery.of(context).viewInsets.bottom == 0,
      child: FadeInUp(
        duration: Duration(milliseconds: 200),
        child: ShadButton(
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          enabled: !entregasProvider.creatingEntrega &&
              productosEntregados.isNotEmpty,
          onPressed: () async {
            if (!formEntrega.currentState!.saveAndValidate()) {
              return;
            }
            if (productosEntregados.isEmpty) {
              return;
            }
            if (entregasProvider.creatingEntrega) {
              return;
            }
            final idComedor = entregasProvider.findIdComedorSolidario(
                formEntrega.currentState?.fields['comedor']!.value);
            if (idComedor == 0) {
              // if (idComedor.isEmpty) {
              return;
            }
            await showAlertDialog(
              context: context,
              description:
                  'Esta accion creará una entrega con los datos indicados.',
              continueFunction: () async {
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
                  SoundPlayer.playSound('positive.wav');
                  throwToastSuccess(
                    context: context,
                    title: 'Entrega ingresada.',
                    descripcion: 'La entrega ha sido ingresada con éxito !',
                  );
                  context.pop();
                });
              },
            ).then((value) {
              if (!context.mounted) {
                return;
              }
              FocusScope.of(context).unfocus();
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
                              Opacity(
                                opacity: carga.cantidad == 0 ? 0.3 : 1.0,
                                child: ShadBadge(
                                  child: AnimatedDigitWidget(
                                    duration: Duration(milliseconds: 400),
                                    value: carga.cantidad,
                                    textStyle: textStyles.small.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
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
