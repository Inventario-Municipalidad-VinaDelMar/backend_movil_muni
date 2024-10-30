import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/src/providers/logistica/entregas/rest/rest_entrega_provider.dart';
import 'package:frontend_movil_muni/src/providers/logistica/entregas/socket/socket_entrega_provider.dart';
import 'package:frontend_movil_muni/src/providers/socket_base.dart';

class EntregaProvider
    with
        ChangeNotifier,
        SocketProviderBase,
        RestEntregaProvider,
        SocketEntregaProvider {
  void initialize() {
    initRest();
    initSocket();
  }
}
