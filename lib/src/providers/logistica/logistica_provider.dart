import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/src/providers/logistica/rest/rest_logistica_provider.dart';
import 'package:frontend_movil_muni/src/providers/logistica/socket/socket_logistica_provider.dart';

class LogisticaProvider
    with ChangeNotifier, RestLogisticaProvider, SocketLogisticaProvider {
  void initialize() {
    initRest();
    initSocket();
  }
}
