import 'package:animate_do/animate_do.dart';
import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:frontend_movil_muni/infraestructure/models/planificacion/detalle_planificacion.dart';
import 'package:frontend_movil_muni/infraestructure/models/planificacion/envio_model.dart';
import 'package:frontend_movil_muni/infraestructure/models/planificacion/solicitud_envio.dart';
import 'package:frontend_movil_muni/src/pages/envios/widgets/handle_toast_solicitud.dart';
import 'package:frontend_movil_muni/src/providers/movimientos/socket/socket_movimiento_provider.dart';
import 'package:frontend_movil_muni/src/providers/planificacion/mixin/socket/socket_planificacion_provider.dart';
import 'package:frontend_movil_muni/src/providers/provider.dart';
import 'package:frontend_movil_muni/src/widgets/confirmation_dialog.dart';
import 'package:frontend_movil_muni/src/widgets/sound/sound_player.dart';
import 'package:frontend_movil_muni/src/widgets/toast/toast_shad.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:audioplayers/audioplayers.dart';

class EnviosPage extends StatefulWidget {
  const EnviosPage({super.key});

  @override
  State<EnviosPage> createState() => _EnviosPageState();
}

class _EnviosPageState extends State<EnviosPage> {
  late PlanificacionProvider _planificacionProvider;
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _planificacionProvider = context.read<PlanificacionProvider>();
    _planificacionProvider.connect(
      [
        PlanificacionEvent.loadSolicitudEnvio,
        PlanificacionEvent.planificacionActual,
        PlanificacionEvent.detallesTakenLoad,
      ],
      onSolicitudReceived: showToastOnSolicitudReceived,
      playSound: playSound,
    );
  }

  @override
  void dispose() {
    _planificacionProvider.disconnect([
      PlanificacionEvent.loadSolicitudEnvio,
      PlanificacionEvent.planificacionActual,
      PlanificacionEvent.detallesTakenLoad,
    ]);

    super.dispose();
  }

  void playSound(String sound) async {
    await player.play(AssetSource('sounds/$sound'));
  }

  void showToastOnSolicitudReceived(SolicitudEnvioModel solicitud) {
    if (solicitud.status == SolicitudStatus.pendiente) {
      return;
    }

    handleToastSolicitud(solicitud, context);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    //final colors = ShadTheme.of(context).colorScheme;
    final textStyles = ShadTheme.of(context).textTheme;
    final planificacionProvider = context.watch<PlanificacionProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.blue[500],
        title: Text(
          'Planificacion',
          style: textStyles.h4.copyWith(
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
      body: planificacionProvider.loadingPlanificacionActual
          ? const Center(child: CircularProgressIndicator())
          : planificacionProvider.planificacionActual!.detalles.isEmpty
              ? Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.2),
                  child: Text(
                    'No hay productos planificados, hable con un administrador.',
                    textAlign: TextAlign.center,
                  ),
                )
              : Column(
                  children: [
                    //Planificacion del dia
                    const _TablePlanificacion(),
                    if (planificacionProvider.planificacionActual != null &&
                        planificacionProvider
                                .planificacionActual?.envioIniciado !=
                            null)
                      //Lista de movimiento en el envio actual
                      _MovimientosList(
                          idEnvio: planificacionProvider
                              .planificacionActual!.envioIniciado!.id),
                    const Spacer(),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        if (!planificacionProvider.processingSolicitud &&
                            !planificacionProvider.loadingPlanificacionActual &&
                            planificacionProvider.solicitudEnCurso != null &&
                            planificacionProvider.solicitudEnCurso?.status ==
                                SolicitudStatus.pendiente)
                          Positioned(
                            top: -(size.height * 0.02),
                            left: size.width * 0.03,
                            child: FadeInLeft(
                              duration: Duration(milliseconds: 200),
                              child: Row(
                                children: [
                                  Text(
                                    'Esperando autorizacion de un administrador...',
                                    style: textStyles.small
                                        .copyWith(color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ShadButton(
                          width: double.infinity,
                          enabled: planificacionProvider.waitingTimeEnvio
                              ? false
                              : planificacionProvider.processingSolicitud
                                  ? false
                                  : planificacionProvider.completingEnvio
                                      ? false
                                      : planificacionProvider
                                                      .solicitudEnCurso !=
                                                  null &&
                                              planificacionProvider
                                                      .solicitudEnCurso
                                                      ?.status ==
                                                  SolicitudStatus.pendiente
                                          ? false
                                          : (planificacionProvider
                                                      .planificacionActual
                                                      ?.envioIniciado !=
                                                  null
                                              ? planificacionProvider
                                                          .planificacionActual
                                                          ?.envioIniciado !=
                                                      null &&
                                                  planificacionProvider
                                                      .planificacionActual!
                                                      .areAllDetailsComplete()
                                              : true),
                          size: ShadButtonSize.lg,
                          onPressed: () async {
                            if (planificacionProvider.waitingTimeEnvio) {
                              return;
                            }
                            if (planificacionProvider.solicitudEnCurso !=
                                    null &&
                                planificacionProvider
                                        .solicitudEnCurso?.status ==
                                    SolicitudStatus.pendiente) {
                              return;
                            }
                            if (planificacionProvider.planificacionActual!
                                .areAllDetailsComplete()) {
                              showAlertDialog(
                                  context: context,
                                  description:
                                      'Esta acción marcará el envio actual con carga completa.',
                                  continueFunction: () async {
                                    await planificacionProvider
                                        .completeCurrentEnvio();
                                    // Timer(const Duration(seconds: 5), () {
                                    SoundPlayer.playSound('positive.wav');
                                    if (!context.mounted) {
                                      return;
                                    }
                                    throwToastSuccess(
                                      context: context,
                                      title: 'Envío con carga completa.',
                                      descripcion:
                                          'El envió se completo con éxito !',
                                    );
                                  });

                              return;
                            }

                            if (planificacionProvider
                                        .planificacionActual?.envioIniciado !=
                                    null &&
                                planificacionProvider.planificacionActual
                                        ?.envioIniciado!.status ==
                                    EnvioStatus.sinCargar) {
                              return;
                            }
                            await planificacionProvider
                                .sendSolicitudAutorizacion();
                          },
                          icon: (planificacionProvider.solicitudEnCurso !=
                                          null &&
                                      planificacionProvider
                                              .solicitudEnCurso?.status ==
                                          SolicitudStatus.pendiente) ||
                                  planificacionProvider.completingEnvio ||
                                  planificacionProvider.processingSolicitud ||
                                  planificacionProvider.waitingTimeEnvio
                              ? null
                              : planificacionProvider
                                          .planificacionActual?.envioIniciado ==
                                      null
                                  ? const Icon(Icons.swipe_up_outlined)
                                  : const Icon(Icons.fire_truck_outlined),
                          child: Row(
                            children: [
                              Text(
                                planificacionProvider.waitingTimeEnvio
                                    ? planificacionProvider.countdownText
                                    : planificacionProvider.processingSolicitud
                                        ? 'Creando solicitud'
                                        : planificacionProvider.completingEnvio
                                            ? 'Completando envio'
                                            : planificacionProvider
                                                            .solicitudEnCurso !=
                                                        null &&
                                                    planificacionProvider
                                                            .solicitudEnCurso
                                                            ?.status ==
                                                        SolicitudStatus
                                                            .pendiente
                                                ? 'Esperando'
                                                : planificacionProvider
                                                            .planificacionActual
                                                            ?.envioIniciado ==
                                                        null
                                                    ? 'Iniciar nuevo envío'
                                                    : 'Completar envío',
                                style:
                                    textStyles.h4.copyWith(color: Colors.white),
                              ),
                              SizedBox(width: 5),
                              if ((planificacionProvider.solicitudEnCurso !=
                                          null &&
                                      planificacionProvider
                                              .solicitudEnCurso?.status ==
                                          SolicitudStatus.pendiente) ||
                                  planificacionProvider.completingEnvio ||
                                  planificacionProvider.processingSolicitud ||
                                  planificacionProvider.waitingTimeEnvio)
                                AnimateIcon(
                                  color: Colors.white,
                                  animateIcon: AnimateIcons.loading6,
                                  width: size.height * 0.027,
                                  height: size.height * 0.027,
                                  onTap: () {},
                                  iconType: IconType.continueAnimation,
                                ),
                              if ((planificacionProvider.solicitudEnCurso ==
                                          null ||
                                      planificacionProvider
                                              .solicitudEnCurso?.status !=
                                          SolicitudStatus.pendiente) &&
                                  !planificacionProvider.completingEnvio &&
                                  !planificacionProvider.processingSolicitud &&
                                  !planificacionProvider.waitingTimeEnvio)
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
    );
  }
}

class _TablePlanificacion extends StatelessWidget {
  const _TablePlanificacion();

  @override
  Widget build(BuildContext context) {
    final planificacionProvider = context.watch<PlanificacionProvider>();
    final userProvider = context.watch<UserProvider>();
    Size size = MediaQuery.of(context).size;
    final textStyles = ShadTheme.of(context).textTheme;

    return SizedBox(
      width: size.width,
      height: size.height * 0.4,
      child: DataTable(
        columnSpacing: size.width * 0.05, // Espaciado entre columnas
        columns: [
          DataColumn(
            label: Text(
              'Nombre',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: size.height * 0.017,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Estado',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: size.height * 0.017,
              ),
            ),
          ),
          DataColumn(
            label: Expanded(
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  'Acción',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: size.height * 0.017,
                  ),
                ),
              ),
            ),
          ),
        ],
        rows:
            planificacionProvider.planificacionActual!.detalles.map((detalle) {
          return DataRow(
            cells: [
              DataCell(
                Row(
                  children: [
                    // CustomAvatar(
                    //   size: size.height * 0.056,
                    //   imageUrl: detalle.urlImagen,
                    // ),
                    ShadAvatar(
                      // size: Size(40, 40),
                      fit: BoxFit.fitHeight,
                      detalle.urlImagen,
                      placeholder: SkeletonAvatar(
                        style: SkeletonAvatarStyle(
                          shape: BoxShape.circle,
                        ),
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                    SizedBox(width: size.width * 0.02),
                    Expanded(
                      // Asegurar que el texto ocupe el espacio necesario
                      child: Text(
                        detalle.producto,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: size.height * 0.015,
                        ),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(
                Center(
                  child: ShadCheckbox(
                    decoration: detalle.isComplete
                        ? const ShadDecoration(border: ShadBorder())
                        : null,
                    enabled: planificacionProvider
                            .planificacionActual?.envioIniciado !=
                        null,
                    value: detalle.isComplete,
                    color: planificacionProvider
                                .planificacionActual?.envioIniciado ==
                            null
                        ? null
                        : detalle.isComplete
                            ? Colors.green
                            : Colors.grey,
                  ),
                ),
              ),
              DataCell(
                Center(
                  child: ShadButton(
                    width: size.width * 0.33,
                    enabled: (planificacionProvider
                                .planificacionActual?.envioIniciado !=
                            null) &&
                        !detalle.isComplete &&
                        planificacionProvider.detallesTaken
                                .firstWhere(
                                    (dt) =>
                                        dt.idDetalle == detalle.id &&
                                        dt.user!.id !=
                                            userProvider.user!
                                                .id, // Condición de búsqueda
                                    orElse: () => DetallesTaken(
                                        idDetalle: '', user: null))
                                .idDetalle ==
                            '',

                    // !planificacionProvider.detalleIsTaken(detalle.id),
                    size: ShadButtonSize.sm,
                    onPressed: planificacionProvider
                                .planificacionActual?.envioIniciado !=
                            null
                        ? () {
                            context.push('/envio/${detalle.productoId}/tandas');
                          }
                        : null,
                    icon: planificacionProvider.detallesTaken
                                .firstWhere(
                                    (dt) =>
                                        dt.idDetalle == detalle.id &&
                                        dt.user!.id !=
                                            userProvider.user!
                                                .id, // Condición de búsqueda
                                    orElse: () => DetallesTaken(
                                        idDetalle: '', user: null))
                                .idDetalle !=
                            ''
                        ? Icon(
                            Icons.account_circle,
                            size: size.width * 0.05,
                          )
                        : Icon(
                            detalle.isComplete
                                ? Icons.checklist_sharp
                                : Icons.search,
                            size: 16,
                          ),
                    child: planificacionProvider.detallesTaken
                                .firstWhere(
                                    (dt) =>
                                        dt.idDetalle == detalle.id &&
                                        dt.user!.id !=
                                            userProvider.user!
                                                .id, // Condición de búsqueda
                                    orElse: () => DetallesTaken(
                                        idDetalle: '', user: null))
                                .idDetalle !=
                            ''
                        ? Text(
                            'Tomada ...',
                            style:
                                textStyles.small.copyWith(color: Colors.white),
                          )
                        : Text(
                            detalle.isComplete ? 'Hecho' : 'Buscar',
                            style:
                                textStyles.small.copyWith(color: Colors.white),
                          ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MovimientosList extends StatefulWidget {
  final String idEnvio;
  const _MovimientosList({required this.idEnvio});

  @override
  State<_MovimientosList> createState() => __MovimientosListState();
}

class __MovimientosListState extends State<_MovimientosList> {
  late MovimientoProvider _movimientoProvider;
  @override
  void initState() {
    super.initState();
    _movimientoProvider = context.read<MovimientoProvider>();
    _movimientoProvider.connect([
      MovimientoEvent.movimientosEnvio,
      MovimientoEvent.movimientoOnEnvio,
    ], id: widget.idEnvio);
  }

  @override
  void dispose() {
    _movimientoProvider.disconnect([
      MovimientoEvent.movimientosEnvio,
      MovimientoEvent.movimientoOnEnvio,
    ], id: widget.idEnvio);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyles = ShadTheme.of(context).textTheme;
    Size size = MediaQuery.of(context).size;
    final movimientoProvider = context.watch<MovimientoProvider>();
    return movimientoProvider.loadingMovimientos
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Column(
            children: [
              Visibility(
                visible: movimientoProvider.movimientos.isNotEmpty,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  width: size.width,
                  height: size.height * 0.04,
                  child: Text(
                    'Movimientos Realizados',
                    style: textStyles.h4,
                  ),
                ),
              ),
              SizedBox(
                width: size.width,
                height: size.height * 0.35,
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  itemCount: movimientoProvider.movimientos.length,
                  itemBuilder: (context, i) {
                    final movimiento = movimientoProvider.movimientos[i];
                    return FadeInRight(
                      duration: Duration(milliseconds: 200),
                      delay: Duration(milliseconds: i * 150),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.only(bottom: size.height * 0.01),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.blue,
                        ),
                        width: double.infinity,
                        height: size.height * 0.09,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                                right: 0,
                                child: Text(
                                  '${movimiento.hora.split(':')[0]}:${movimiento.hora.split(':')[1]} ${movimiento.getMedioDia()}',
                                  style: textStyles.small.copyWith(
                                    color: Colors.white,
                                  ),
                                )),
                            Row(
                              children: [
                                FadeIn(
                                  child: ShadAvatar(
                                    movimiento.realizador.imageUrl ??
                                        'https://app.requestly.io/delay/2000/avatars.githubusercontent.com/u/124599?v=4',
                                    placeholder: const SkeletonAvatar(
                                      style: SkeletonAvatarStyle(
                                          shape: BoxShape.circle,
                                          width: 50,
                                          height: 50),
                                    ),
                                    backgroundColor: Colors.transparent,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${movimiento.realizador.nombre} ${movimiento.realizador.apellidoPaterno} ${movimiento.realizador.apellidoMaterno}',
                                      style: textStyles.p.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: size.height * 0.02,
                                      ),
                                      // textScaler: TextScaler.linear(.7),
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: size.width * 0.22,
                                          child: Text(
                                            'Retiró ${movimiento.cantidadRetirada} de',
                                            style: textStyles.small.copyWith(
                                              color: Colors.grey[300],
                                              fontSize: size.height * 0.017,
                                            ),
                                          ),
                                        ),
                                        // SizedBox(width: 10),
                                        ShadBadge(
                                          padding: EdgeInsets.symmetric(
                                              vertical: size.height * 0.0025,
                                              horizontal: 10),
                                          child: Text(
                                            movimiento.producto,
                                            style: textStyles.small.copyWith(
                                              fontSize: size.height * 0.017,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
  }
}
