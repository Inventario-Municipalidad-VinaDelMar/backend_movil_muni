import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/src/providers/planificacion/mixin/rest/rest_planificacion_provider.dart';
import 'package:frontend_movil_muni/src/providers/planificacion/mixin/socket/socket_planificacion_provider.dart';
import 'package:frontend_movil_muni/src/providers/socket_base.dart';

class PlanificacionProvider
    with
        ChangeNotifier,
        SocketProviderBase,
        RestPlanificacionProvider,
        SocketPlanificacionProvider {
  void initialize() {
    initRest();
    initSocket();
  }
}
