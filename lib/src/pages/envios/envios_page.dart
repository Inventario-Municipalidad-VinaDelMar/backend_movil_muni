import 'package:animate_do/animate_do.dart';
import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:frontend_movil_muni/infraestructure/models/planificacion/envio_model.dart';
import 'package:frontend_movil_muni/infraestructure/models/planificacion/solicitud_envio.dart';
import 'package:frontend_movil_muni/src/providers/movimientos/movimiento_provider.dart';
import 'package:frontend_movil_muni/src/providers/movimientos/socket/socket_movimiento_provider.dart';
import 'package:frontend_movil_muni/src/providers/planificacion/mixin/socket/socket_planificacion_provider.dart';
import 'package:frontend_movil_muni/src/providers/planificacion/planificacion_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class EnviosPage extends StatefulWidget {
  const EnviosPage({super.key});

  @override
  State<EnviosPage> createState() => _EnviosPageState();
}

class _EnviosPageState extends State<EnviosPage> {
  late PlanificacionProvider _planificacionProvider;
  @override
  void initState() {
    _planificacionProvider = context.read<PlanificacionProvider>();
    _planificacionProvider.connect([
      PlanificacionEvent.loadSolicitudEnvio,
      PlanificacionEvent.planificacionActual,
    ]);
    super.initState();
  }

  @override
  void dispose() {
    _planificacionProvider.disconnect([
      PlanificacionEvent.loadSolicitudEnvio,
      PlanificacionEvent.planificacionActual,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    //final colors = ShadTheme.of(context).colorScheme;
    final textStyles = ShadTheme.of(context).textTheme;
    final planificacionProvider = context.watch<PlanificacionProvider>();

    return Scaffold(
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
          : Column(
              children: [
                //Planificacion del dia
                const _TablePlanificacion(),
                if (planificacionProvider.planificacionActual.isNotEmpty &&
                    planificacionProvider
                            .planificacionActual.first.envioIniciado !=
                        null)
                  //Lista de movimiento en el envio actual
                  _MovimientosList(
                      idEnvio: planificacionProvider
                          .planificacionActual[0].envioIniciado!.id),
                const Spacer(),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    if (!planificacionProvider.processingSolicitud &&
                        !planificacionProvider.loadingPlanificacionActual &&
                        planificacionProvider.solicitudEnCurso.isNotEmpty &&
                        planificacionProvider.solicitudEnCurso[0].status ==
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
                                              .solicitudEnCurso.isNotEmpty &&
                                          planificacionProvider
                                                  .solicitudEnCurso[0].status ==
                                              SolicitudStatus.pendiente
                                      ? false
                                      : (planificacionProvider
                                                  .planificacionActual[0]
                                                  .envioIniciado !=
                                              null
                                          ? planificacionProvider
                                                      .planificacionActual[0]
                                                      .envioIniciado !=
                                                  null &&
                                              planificacionProvider
                                                  .planificacionActual[0]
                                                  .areAllDetailsComplete()
                                          : true),
                      size: ShadButtonSize.lg,
                      onPressed: () async {
                        if (planificacionProvider.waitingTimeEnvio) {
                          return;
                        }
                        if (planificacionProvider.solicitudEnCurso.isNotEmpty &&
                            planificacionProvider.solicitudEnCurso[0].status ==
                                SolicitudStatus.pendiente) {
                          return;
                        }
                        if (planificacionProvider.planificacionActual[0]
                            .areAllDetailsComplete()) {
                          await planificacionProvider.completeCurrentEnvio();
                          return;
                        }

                        if (planificacionProvider
                                    .planificacionActual[0].envioIniciado !=
                                null &&
                            planificacionProvider.planificacionActual[0]
                                    .envioIniciado!.status ==
                                EnvioStatus.sinCargar) {
                          return;
                        }
                        await planificacionProvider.sendSolicitudAutorizacion();
                      },
                      icon:
                          (planificacionProvider.solicitudEnCurso.isNotEmpty &&
                                      planificacionProvider
                                              .solicitudEnCurso[0].status ==
                                          SolicitudStatus.pendiente) ||
                                  planificacionProvider.completingEnvio ||
                                  planificacionProvider.processingSolicitud ||
                                  planificacionProvider.waitingTimeEnvio
                              ? null
                              : planificacionProvider.planificacionActual[0]
                                          .envioIniciado ==
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
                                        : planificacionProvider.solicitudEnCurso
                                                    .isNotEmpty &&
                                                planificacionProvider
                                                        .solicitudEnCurso[0]
                                                        .status ==
                                                    SolicitudStatus.pendiente
                                            ? 'Esperando'
                                            : planificacionProvider
                                                        .planificacionActual[0]
                                                        .envioIniciado ==
                                                    null
                                                ? 'Iniciar nuevo envío'
                                                : 'Completar envío',
                            style: textStyles.h4.copyWith(color: Colors.white),
                          ),
                          SizedBox(width: 5),
                          if ((planificacionProvider
                                      .solicitudEnCurso.isNotEmpty &&
                                  planificacionProvider
                                          .solicitudEnCurso[0].status ==
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
                          if ((planificacionProvider.solicitudEnCurso.isEmpty ||
                                  planificacionProvider
                                          .solicitudEnCurso[0].status !=
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
        rows: planificacionProvider.planificacionActual[0].detalles
            .map((detalle) {
          return DataRow(
            cells: [
              DataCell(
                Row(
                  children: [
                    ShadAvatar(
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
                            .planificacionActual[0].envioIniciado !=
                        null,
                    value: detalle.isComplete,
                    color: planificacionProvider
                                .planificacionActual[0].envioIniciado ==
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
                    enabled: (planificacionProvider
                                .planificacionActual[0].envioIniciado !=
                            null) &&
                        !detalle.isComplete,
                    size: ShadButtonSize.sm,
                    onPressed: planificacionProvider
                                .planificacionActual[0].envioIniciado !=
                            null
                        ? () {
                            context.push('/envio/${detalle.productoId}/tandas');
                          }
                        : null,
                    icon: Icon(
                      detalle.isComplete ? Icons.checklist_sharp : Icons.search,
                      size: 16,
                    ),
                    child: Text(
                      detalle.isComplete ? 'Hecho' : 'Buscar',
                      style: textStyles.small.copyWith(color: Colors.white),
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
    _movimientoProvider = context.read<MovimientoProvider>();
    _movimientoProvider.connect([
      MovimientoEvent.movimientosEnvio,
      MovimientoEvent.movimientoOnEnvio,
    ], id: widget.idEnvio);
    super.initState();
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${movimiento.realizador.nombre} ${movimiento.realizador.apellidoPaterno} ${movimiento.realizador.apellidoMaterno}',
                                      style: textStyles.p.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: size.width * 0.22,
                                          child: Text(
                                            'Retiró ${movimiento.cantidadRetirada} de',
                                            style: textStyles.small.copyWith(
                                              color: Colors.grey[300],
                                            ),
                                          ),
                                        ),
                                        // SizedBox(width: 10),
                                        ShadBadge(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 0, horizontal: 10),
                                          child: Text(
                                            movimiento.producto,
                                            // style: textStyles.small.co,
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
