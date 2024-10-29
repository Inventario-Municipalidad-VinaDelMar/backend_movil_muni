import 'dart:async';

import 'package:frontend_movil_muni/infraestructure/models/movimiento/movimiento_model.dart';
import 'package:frontend_movil_muni/src/providers/socket_base.dart';

enum MovimientoEvent {
  movimientosEnvio,
  movimientoOnEnvio,
}

class SocketEvents {
  //Emiten al servidor para preguntar por datos
  static const String getMovimientos = 'getMovimientosByEnvio';

  //Reciben informacion desde el server como listener
  static const String loadMovimientos = '-loadMovimientos';
  static const String newMovimientoOnEnvio = 'newMovimientoOnEnvio';
}

mixin SocketMovimientoProvider on SocketProviderBase {
  @override
  String get namespace => 'movimientos';
  //Siempre existirá solo 1 elemento en esta lista.
  List<MovimientoModel> movimientos = [];

  bool loadingMovimientos = false;

  final Map<MovimientoEvent, Timer?> _timers = {};
  final Map<MovimientoEvent, bool> connectionTimeouts = {
    MovimientoEvent.movimientosEnvio: false,
    //Añadir mas si creas mas evento
  };

  void connect(List<MovimientoEvent> events, {String? id}) {
    _clearListeners(events, idEnvio: id);
    _registerListeners(events, idEnvio: id);
  }

  void disconnect(List<MovimientoEvent> events, {String? id}) {
    _clearListeners(events, idEnvio: id);
    //?Probando si sirve esta linea
    movimientos.clear();
  }

  void _registerListeners(List<MovimientoEvent> events, {String? idEnvio}) {
    if (socket == null) return;
    for (var event in events) {
      switch (event) {
        case MovimientoEvent.movimientosEnvio:
          if (idEnvio == null) {
            print('Id envio es null: $idEnvio');
            return;
          }
          handleSocketEvent<MovimientoModel>(
            emitEvent: SocketEvents.getMovimientos,
            loadEvent: '$idEnvio${SocketEvents.loadMovimientos}',
            dataList: movimientos,
            setLoading: (loading) => loadingMovimientos = loading,
            fromApi: (data) => MovimientoModel.fromApi(data),
            emitPayload: {
              'idEnvio': idEnvio,
            },
            // extraAction: async(p0, p1) {
            //    await Future.delayed(Duration(seconds: 1));
            // },
          );
          break;
        case MovimientoEvent.movimientoOnEnvio:
          handleNewEntityEvent<MovimientoModel>(
            newEvent: SocketEvents.newMovimientoOnEnvio,
            setEntity: (movimiento) {
              movimientos.add(movimiento);
              notifyListeners();
            },
            fromApi: (data) => MovimientoModel.fromApi(data),
          );
          break;

        default:
          print('Evento no manejado, en MovimientosSocker: $event');
      }
    }
  }

  void _clearListeners(events, {String? idEnvio}) {
    if (socket == null) return;
    for (var event in events) {
      switch (event) {
        case MovimientoEvent.movimientosEnvio:
          socket?.off('$idEnvio${SocketEvents.loadMovimientos}');
          break;
        case MovimientoEvent.movimientoOnEnvio:
          socket?.off(SocketEvents.newMovimientoOnEnvio);
          break;
      }
    }
  }
}
