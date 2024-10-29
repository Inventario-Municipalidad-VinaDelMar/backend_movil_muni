import 'dart:async';
import 'package:frontend_movil_muni/infraestructure/models/logistica/envio_logistico_model.dart';
import 'package:frontend_movil_muni/src/providers/socket_base.dart';
import 'package:frontend_movil_muni/src/utils/dates_utils.dart';

enum EnvioEvent {
  enviosByFecha,
  newEnvio,
}

class SocketEvents {
  //Emiten al servidor para preguntar por datos
  static const String getEnviosByFecha = 'getEnviosByFecha';

  //Reciben informacion desde el server como listener
  static const String loadEnviosByFecha = 'loadEnviosByFecha';
}

mixin SocketEnvioProvider on SocketProviderBase {
  @override
  String get namespace => 'logistica/envios';
  //Siempre existirá solo 1 elemento en esta lista.
  List<EnvioLogisticoModel> enviosLogisticos = [];
  bool loadingEnvios = false;

  final Map<EnvioEvent, Timer?> _timers = {};
  final Map<EnvioEvent, bool> connectionTimeouts = {
    EnvioEvent.enviosByFecha: false,
    //Añadir mas si creas mas evento
  };

  void connect(List<EnvioEvent> events) {
    _clearListeners(events);
    _registerListeners(events);
  }

  void disconnect(
    List<EnvioEvent> events,
  ) {
    _clearListeners(events);
  }

  void _registerListeners(List<EnvioEvent> events) {
    if (socket == null) return;
    for (var event in events) {
      switch (event) {
        case EnvioEvent.enviosByFecha:
          handleSocketEvent<EnvioLogisticoModel>(
            emitEvent: SocketEvents.getEnviosByFecha,
            loadEvent: SocketEvents.loadEnviosByFecha,
            dataList: enviosLogisticos,
            setLoading: (loading) => loadingEnvios = loading,
            fromApi: (data) => EnvioLogisticoModel.fromApi(data),
            emitPayload: {
              'fecha': getFormattedDate(),
            },
          );
          break;

        default:
          print('Evento no manejado, en LogisticaEnviosSocket: $event');
      }
    }
  }

  void _clearListeners(events) {
    if (socket == null) return;
    for (var event in events) {
      switch (event) {
        case EnvioEvent.enviosByFecha:
          socket?.off(SocketEvents.loadEnviosByFecha);
          break;
      }
    }
  }
}
