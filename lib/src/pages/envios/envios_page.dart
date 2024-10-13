import 'package:flutter/material.dart';
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
      PlanificacionEvent.planificacionActual,
    ]);
    super.initState();
  }

  @override
  void dispose() {
    _planificacionProvider.disconnect([
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
        title: const Text('Planificacion'),
      ),
      body: planificacionProvider.loadingPlanificacionActual
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SizedBox(
                  width: size.width,
                  height: size.height * 0.82,
                  child: ShadTable.list(
                    columnSpanExtent: (index) {
                      if (index == 0) {
                        return FixedTableSpanExtent(size.width * 0.3);
                      }
                      if (index == 1) {
                        return FixedTableSpanExtent(size.width * 0.3);
                      }
                      if (index == 2) {
                        return MaxTableSpanExtent(
                          FixedTableSpanExtent(size.width * 0.15),
                          const RemainingTableSpanExtent(),
                        );
                      }
                      return null;
                    },
                    header: [
                      ShadTableCell.header(
                        child: Text(
                          'Nombre',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: size.height * 0.017),
                        ),
                      ),
                      ShadTableCell.header(
                        child: Text(
                          'Completado',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: size.height * 0.017),
                        ),
                      ),
                      ShadTableCell.header(
                        alignment: Alignment.center,
                        child: Text(
                          'Accion',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: size.height * 0.017),
                        ),
                      ),
                    ],
                    children:
                        planificacionProvider.planificacionActual[0].detalles
                            .map(
                              (detalle) => [
                                ShadTableCell(
                                  child: Text(
                                    detalle.producto,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: size.height * 0.015),
                                  ),
                                ),
                                ShadTableCell(
                                  child: Center(
                                    child: ShadCheckbox(
                                      decoration: detalle.isComplete
                                          ? const ShadDecoration(
                                              border: ShadBorder())
                                          : null,
                                      enabled: planificacionProvider
                                              .planificacionActual[0]
                                              .envioIniciado !=
                                          null,
                                      value: detalle.isComplete,
                                      color: planificacionProvider
                                                  .planificacionActual[0]
                                                  .envioIniciado ==
                                              null
                                          ? null
                                          : detalle.isComplete
                                              ? Colors.green
                                              : Colors.grey,
                                    ),
                                  ),
                                ),
                                ShadTableCell(
                                  child: SizedBox(
                                    height: size.height * 0.045,
                                    child: Center(
                                      child: ShadButton(
                                        enabled: planificacionProvider
                                                .planificacionActual[0]
                                                .envioIniciado !=
                                            null,
                                        size: ShadButtonSize.sm,
                                        onPressed: planificacionProvider
                                                    .planificacionActual[0]
                                                    .envioIniciado !=
                                                null
                                            ? () {
                                                context.push(
                                                    '/envio/${detalle.productoId}/tandas');
                                              }
                                            : null,
                                        icon: const Icon(
                                          Icons.search,
                                          size: 13,
                                        ),
                                        child: Text(
                                          'Buscar',
                                          style: textStyles.small
                                              .copyWith(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                            .toList(),
                  ),
                ),
                const Spacer(),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    //TODO: En espera de confirmacion de solicitud
                    if (false)
                      Positioned(
                        top: -(size.height * 0.02),
                        left: size.width * 0.03,
                        child: Text(
                          'Esperando autorizacion de un administrador...',
                          style: textStyles.small,
                        ),
                      ),
                    ShadButton(
                      width: double.infinity,
                      enabled: planificacionProvider
                                  .planificacionActual[0].envioIniciado !=
                              null
                          ? planificacionProvider
                                      .planificacionActual[0].envioIniciado !=
                                  null &&
                              planificacionProvider.planificacionActual[0]
                                  .areAllDetailsComplete()
                          : true,
                      size: ShadButtonSize.lg,
                      onPressed: () {
                        // setState(() {
                        //   if (envioIniciado) {
                        //     Navigator.pop(context);
                        //   } else {
                        //     envioIniciado = !envioIniciado;
                        //   }
                        // });
                      },
                      icon: const Icon(Icons.swipe_up_outlined),
                      child: Text(
                        planificacionProvider
                                    .planificacionActual[0].envioIniciado ==
                                null
                            ? 'Iniciar nuevo envío'
                            : 'Completar envío',
                        style: textStyles.h4.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
