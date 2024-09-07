import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/src/providers/inventario/mixin/rest/rest_inventario_provider.dart';
import 'package:frontend_movil_muni/src/providers/inventario/mixin/socket/socket_inventario_provider.dart';

class InventarioProvider
    with ChangeNotifier, RestInventarioProvider, SocketInventarioProvider {
  void initialize() {
    initRest();
    initSocket();
  }
}
