import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/infraestructure/models/movimiento/movimiento_model.dart';
import 'package:frontend_movil_muni/src/providers/planificacion/mixin/rest/rest_planificacion_provider.dart';
import 'package:frontend_movil_muni/src/providers/planificacion/mixin/socket/socket_planificacion_provider.dart';

class PlanificacionProvider
    with
        ChangeNotifier,
        RestPlanificacionProvider,
        SocketPlanificacionProvider {
  List<MovimientoModel> movimientos = [];

  void initialize() {
    initRest();
    initSocket();
  }
}
