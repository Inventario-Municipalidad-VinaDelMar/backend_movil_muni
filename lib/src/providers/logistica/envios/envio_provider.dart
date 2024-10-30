import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/infraestructure/models/logistica/envio_logistico_model.dart';
import 'package:frontend_movil_muni/src/providers/logistica/envios/rest/rest_envio_provider.dart';
import 'package:frontend_movil_muni/src/providers/logistica/envios/socket/socket_envio_provider.dart';
import 'package:frontend_movil_muni/src/providers/socket_base.dart';

class EnvioProvider
    with
        ChangeNotifier,
        SocketProviderBase,
        RestEnvioProvider,
        SocketEnvioProvider {
  void initialize() {
    initRest();
    initSocket();
  }

  EnvioLogisticoModel? findEnvioById(String idEnvio) {
    findById(obj) => obj.id == idEnvio;
    var result = enviosLogisticos.where(findById);
    return result.isNotEmpty ? result.first : null;
  }
}
