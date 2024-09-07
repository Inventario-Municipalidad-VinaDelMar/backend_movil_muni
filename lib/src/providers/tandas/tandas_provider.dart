import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/src/providers/tandas/mixin/rest/rest_tandas_provider.dart';
import 'package:frontend_movil_muni/src/providers/tandas/mixin/socket/socket_tandas_provider.dart';

class TandasProvider
    with ChangeNotifier, RestTandasProvider, SocketTandaProvider {
  void initialize() {
    initRest();
    initSocket();
  }
}
