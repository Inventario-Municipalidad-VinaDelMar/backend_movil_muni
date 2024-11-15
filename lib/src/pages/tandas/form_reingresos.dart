import 'package:animate_do/animate_do.dart';
import 'package:animated_icon/animated_icon.dart';
import 'package:color_mesh/color_mesh.dart';
import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/config/router/main_router.dart';
import 'package:frontend_movil_muni/infraestructure/models/logistica/envio_logistico_model.dart';
import 'package:frontend_movil_muni/infraestructure/models/planificacion/envio_model.dart';
import 'package:frontend_movil_muni/src/pages/entregas/widgets/common/style_by_status.dart';
import 'package:frontend_movil_muni/src/providers/logistica/envios/envio_provider.dart';
import 'package:frontend_movil_muni/src/providers/logistica/envios/socket/socket_envio_provider.dart';
import 'package:frontend_movil_muni/src/widgets/confirmation_dialog.dart';
import 'package:frontend_movil_muni/src/widgets/generic_text_input.dart';
import 'package:frontend_movil_muni/src/widgets/sound/sound_player.dart';
import 'package:frontend_movil_muni/src/widgets/time_since.dart';
import 'package:frontend_movil_muni/src/widgets/toast/toast_shad.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class FormReingresos extends StatefulWidget {
  const FormReingresos({super.key});

  @override
  State<FormReingresos> createState() => _FormReingresosState();
}

class _FormReingresosState extends State<FormReingresos> {
  late EnvioProvider _envioProvider;
  EnvioLogisticoModel? envioSelected;
  int? indexSelected;
  List<ProductoEnvio> productos = [];
  TextEditingController controllerComentario = TextEditingController();
  ScrollController singleChildSc = ScrollController();
  final formKey = GlobalKey<ShadFormState>();
  @override
  void initState() {
    _envioProvider = context.read<EnvioProvider>();
    _envioProvider.connect([EnvioEvent.enviosByFecha]);
    super.initState();
  }

  @override
  void dispose() {
    _envioProvider.disconnect([EnvioEvent.enviosByFecha]);
    super.dispose();
  }

  Future<void> scrollToBottom() async {
    int delay = 500;
    await Future.delayed(Duration(milliseconds: delay));
    singleChildSc.animateTo(
      singleChildSc.position.maxScrollExtent,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final textStyles = ShadTheme.of(context).textTheme;
    final envioProvider = context.watch<EnvioProvider>();
    final enviosFinalizados = envioProvider.enviosLogisticos
        .where((envio) =>
            // envio.status == EnvioStatus.enEnvio ||
            envio.status == EnvioStatus.finalizado)
        .toList();
    return Scaffold(
      backgroundColor: Colors.white,
      // backgroundColor: Colors.grey[200],
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue[500],
        title: Text(
          'Re-ingresar productos',
          style: textStyles.h4.copyWith(
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: singleChildSc,
        child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.05,
              vertical: size.height * 0.02,
            ),
            child: envioProvider.loadingEnvios
                ? Center(
                    child: CircularProgressIndicator(
                    color: Colors.blue[700],
                  ))
                : enviosFinalizados.isEmpty
                    ? SizedBox(
                        width: size.width,
                        height: size.height * 0.8,
                        // color: Colors.blue[700],
                        child: Column(
                          children: [
                            SizedBox(height: size.height * 0.1),
                            SizedBox(
                              width: double.infinity,
                              height: size.height * 0.2,
                              child: Row(
                                children: [
                                  Image.asset('assets/logos/manos.gif'),
                                  Image.asset('assets/logos/route.gif'),
                                ],
                              ),
                            ),
                            Text(
                              'No hay envios disponibles.',
                              style: textStyles.p.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: size.height * 0.02),
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: textStyles.small.copyWith(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.normal,
                                ), // Estilo base para todo el texto
                                children: const [
                                  TextSpan(
                                    text: 'Solo se pueden re-ingresar ',
                                  ),
                                  TextSpan(
                                    text: 'productos sobrantes',
                                    style: TextStyle(
                                        fontWeight: FontWeight
                                            .bold), // Texto en negrita
                                  ),
                                  TextSpan(
                                    text: ' o ',
                                  ),
                                  TextSpan(
                                    text: 'no entregados',
                                    style: TextStyle(
                                        fontWeight: FontWeight
                                            .bold), // Otro texto en negrita
                                  ),
                                  TextSpan(
                                    text: ' de algun envio.',
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: size.height * 0.03),
                            ShadButton(
                              onPressed: () => context.pop(),
                              child: Text('Volver atrás'),
                            ),
                          ],
                        ),
                      )
                    : Builder(
                        builder: (context) {
                          bool anyProduct = (envioSelected?.productos ?? [])
                              .any((producto) => producto.cantidad > 0);

                          return ShadForm(
                            key: formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Para hacer una devolución de productos, seleccione de que envío provienen:',
                                  style: textStyles.p.copyWith(
                                    color: Colors.black87,
                                    height: 1.0,
                                  ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  height: size.height * 0.36,
                                  // color: Colors.red,
                                  child: ListView.builder(
                                    padding: EdgeInsets.symmetric(
                                        vertical: size.height * 0.03),
                                    scrollDirection: Axis.horizontal,
                                    physics: BouncingScrollPhysics(),
                                    itemCount: enviosFinalizados.length,
                                    itemBuilder: (context, i) {
                                      final envio = enviosFinalizados[i];

                                      return Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          splashColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          // overlayColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () {
                                            setState(() {
                                              indexSelected = i;
                                              envioSelected = envio;
                                              productos.clear();
                                            });
                                            setState(() {
                                              productos =
                                                  List.from(envio.productos);
                                            });
                                            scrollToBottom();
                                          },
                                          child: Opacity(
                                            // opacity: 1,
                                            opacity:
                                                i == indexSelected ? 1 : .6,
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                  right: size.width * 0.05),
                                              child: _MiniCardEnvio(
                                                envio: envio,
                                                indexSelected: indexSelected,
                                                currentIndex: i,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                if (envioSelected == null)
                                  FadeInLeft(
                                    duration: Duration(milliseconds: 200),
                                    child: Text(
                                      'Solo figuran envios "finalizados".',
                                      style: textStyles.small.copyWith(
                                        color: Colors.black38,
                                      ),
                                    ),
                                  ),
                                if (envioSelected != null) ...[
                                  FadeInLeft(
                                    duration: Duration(milliseconds: 200),
                                    child: GenericTextInput(
                                      controller: controllerComentario,
                                      maxLength: 87,
                                      maxLines: 2,
                                      labelText: 'Comentario',
                                      placeHolder: 'Razón de la devolución...',
                                      id: 'comentario',
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Es necesario comentar la razón de la devolución';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.height * 0.015,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text(
                                      'Productos a re-ingresar',
                                      style: textStyles.p.copyWith(
                                        color: Colors.black87,
                                        height: 1.0,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.height * 0.015,
                                  ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: BouncingScrollPhysics(),
                                    itemCount: productos.length,
                                    itemBuilder: (context, i) {
                                      final producto = productos[i];
                                      return FadeInRight(
                                        duration: Duration(milliseconds: 200),
                                        delay: Duration(milliseconds: i * 150),
                                        child: Opacity(
                                          opacity: producto.cantidad <= 0
                                              ? 0.5
                                              : 1.0,
                                          child: AnimatedContainer(
                                              duration:
                                                  Duration(milliseconds: 200),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: size.width * 0.03,
                                                vertical: size.height * 0.01,
                                              ),
                                              margin: EdgeInsets.only(
                                                  bottom: size.height * 0.01),
                                              width: double.infinity,
                                              // height: size.height * 0.1,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                gradient: LinearGradient(
                                                  begin: Alignment.bottomLeft,
                                                  end: Alignment.topRight,
                                                  colors: [
                                                    Colors.lightBlueAccent,
                                                    Colors.blue[700]!,
                                                  ],
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        producto.producto,
                                                        style: textStyles.small
                                                            .copyWith(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      Spacer(),
                                                    ],
                                                  ),
                                                  // SizedBox(
                                                  //   height: size.height * 0.008,
                                                  // ),
                                                  Row(
                                                    children: [
                                                      SizedBox(
                                                        width:
                                                            size.height * 0.05,
                                                        height:
                                                            size.height * 0.05,
                                                        child: ShadAvatar(
                                                          producto.urlImagen,
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                        ),
                                                      ),
                                                      Spacer(),
                                                      ShadBadge(
                                                        backgroundColor:
                                                            Colors.orange[600],
                                                        child: producto
                                                                    .cantidad <=
                                                                0
                                                            ? Text(
                                                                'No hay unidades disponibles.')
                                                            : Text(
                                                                'Se re-ingresarán --> ${producto.cantidad}   unidades',
                                                              ),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              )),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(
                                    height: size.height * 0.02,
                                  ),
                                  ShadButton(
                                    enabled: anyProduct &&
                                        !envioProvider.proccesingDevolucion,
                                    onPressed: () async {
                                      if (!formKey.currentState!
                                          .saveAndValidate()) {
                                        return;
                                      }
                                      if (envioSelected == null) {
                                        return;
                                      }
                                      await showAlertDialog(
                                        context: context,
                                        description:
                                            'Esta accion iniciará el proceso de devolución, será un accion irreversible que impactará el stock del inventario.',
                                        continueFunction: () async {
                                          try {
                                            await envioProvider
                                                .initDevolucionProccess(
                                                    envioSelected!.id, {
                                              'comentario': formKey
                                                  .currentState!
                                                  .fields['comentario']
                                                  ?.value
                                            });
                                            if (!context.mounted) {
                                              return;
                                            }
                                            SoundPlayer.playSound(
                                                'positive.wav');
                                            throwToastSuccess(
                                                context: context,
                                                title: 'Devolucion exitosa',
                                                descripcion:
                                                    'La devolución se proceso correctamente.');
                                            context.pop();
                                          } catch (e) {
                                            if (!context.mounted) {
                                              return;
                                            }
                                            SoundPlayer.playSound(
                                                'negative.wav');
                                            throwToastError(
                                                context: context,
                                                descripcion:
                                                    'Reintente de nuevo.');
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
                                    width: double.infinity,
                                    child: anyProduct
                                        ? envioProvider.proccesingDevolucion
                                            ? ZoomIn(
                                                duration:
                                                    Duration(milliseconds: 300),
                                                child: Row(
                                                  children: [
                                                    AnimateIcon(
                                                      color: Colors.white,
                                                      onTap: () {},
                                                      width: size.height * 0.04,
                                                      height:
                                                          size.height * 0.04,
                                                      iconType: IconType
                                                          .continueAnimation,
                                                      animateIcon:
                                                          AnimateIcons.loading6,
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            size.width * 0.02),
                                                    Text(
                                                        'Procesando devolución'),
                                                  ],
                                                ),
                                              )
                                            : ZoomIn(
                                                duration:
                                                    Duration(milliseconds: 500),
                                                child: Text(
                                                    'Confirmar devolución'),
                                              )
                                        : ZoomIn(
                                            duration:
                                                Duration(milliseconds: 500),
                                            child: Text(
                                                'No es posible una devolución'),
                                          ),
                                  )
                                ]
                              ],
                            ),
                          );
                        },
                      )),
      ),
    );
  }
}

class _MiniCardEnvio extends StatelessWidget {
  final EnvioLogisticoModel envio;
  final int? indexSelected;
  final int currentIndex;
  const _MiniCardEnvio({
    required this.envio,
    this.indexSelected,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final colors = ShadTheme.of(context).colorScheme;
    final textStyles = ShadTheme.of(context).textTheme;
    final statusStyle = getStatusStyle(envio);
    bool selected = indexSelected != null && currentIndex == indexSelected;
    TextStyle valueStyle = textStyles.small.copyWith(
      color: Colors.white.withOpacity(.9),
      fontWeight: FontWeight.normal,
      height: 1.45,
    );
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: size.width * 0.5,
      height: size.height * 0.3,
      decoration: BoxDecoration(
        boxShadow: !selected
            ? []
            : [
                BoxShadow(
                  color: Colors.blue.withOpacity(.42),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: Offset(4, 3),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AnimatedMeshGradientContainer(
          gradient: MeshGradient(
            colors: [
              Colors.blue[500]!,
              Colors.blueAccent,
              Colors.blueAccent[700]!,
              Colors.blue,
            ],
            offsets: const [
              Offset(0, 0), // topLeft
              Offset(0, 1), // topRight
              Offset(1, 0), // bottomLeft
              Offset(1, 1), // bottomRight
            ],
          ),
          duration: Duration(milliseconds: 1000),
          child: Padding(
            padding: EdgeInsets.only(
              top: size.height * 0.01,
              bottom: size.height * 0.013,
              left: size.width * 0.03,
              right: size.width * 0.03,
            ),
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: size.width * 0.38,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: size.height * 0.001,
                  ),
                  decoration: BoxDecoration(
                    color: statusStyle['color'],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: !selected
                        ? []
                        : [
                            BoxShadow(
                              color: (statusStyle['textColor'] as Color)
                                  .withOpacity(.2),
                              blurRadius: 8,
                              spreadRadius: 1,
                              offset: Offset(4, 2),
                            ),
                          ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        statusStyle['icon'],
                        color: statusStyle['textColor'],
                        size: size.height * 0.03,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusStyle['label'],
                        style: TextStyle(
                          color: statusStyle['textColor'],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.006),
                Row(
                  children: [
                    Text(
                      'Fecha',
                      style: textStyles.small.copyWith(color: Colors.white),
                    ),
                    Spacer(),
                    Text(envio.getFechaFormatted(), style: valueStyle),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Creacion',
                      style: textStyles.small.copyWith(color: Colors.white),
                    ),
                    Spacer(),
                    Text(envio.getHoraCreacionFormatted(), style: valueStyle),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Finalizacion',
                      style: textStyles.small.copyWith(color: Colors.white),
                    ),
                    Spacer(),
                    Text(envio.getHoraFinalizacionFormatted(),
                        style: valueStyle),
                  ],
                ),
                SizedBox(height: size.height * 0.008),
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tiempo en envio',
                        style: textStyles.small.copyWith(color: Colors.white),
                      ),
                      envio.horaInicioEnvio == null
                          ? Text(
                              '-',
                              style: valueStyle,
                            )
                          : TimeSinceWidget(
                              horaInicioEnvio: envio.horaInicioEnvio!,
                              horaFinalizacion: envio.horaFinalizacion,
                              style: valueStyle,
                            ),
                    ],
                  ),
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                Spacer(),
                SizedBox(
                  height: size.height * 0.07,
                  width: double.infinity,
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: envio.productos.length,
                    itemBuilder: (context, i) {
                      final producto = envio.productos[i];
                      return Container(
                        margin: EdgeInsets.only(right: size.width * 0.01),

                        // width: size.height * 0.01,
                        // height: size.height * 0.01,
                        child: ShadAvatar(
                          producto.urlImagen,
                          backgroundColor: Colors.transparent,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
