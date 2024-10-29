import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/src/providers/movimientos/rest/rest_movimiento_provider.dart';
import 'package:frontend_movil_muni/src/providers/movimientos/socket/socket_movimiento_provider.dart';
import 'package:frontend_movil_muni/src/providers/socket_base.dart';

class MovimientoProvider
    with
        ChangeNotifier,
        SocketProviderBase,
        RestMovimientoProvider,
        SocketMovimientoProvider {
  void initialize() {
    initRest();
    initSocket();
  }
}
