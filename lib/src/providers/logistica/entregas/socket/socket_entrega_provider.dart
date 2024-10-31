import 'dart:async';
import 'package:frontend_movil_muni/infraestructure/models/logistica/comedor_solidario_model.dart';
import 'package:frontend_movil_muni/infraestructure/models/logistica/entrega_model.dart';
import 'package:frontend_movil_muni/src/providers/socket_base.dart';

enum EntregaEvent {
  comedoresSolidarios,
  entregasByEnvio,
  entregaById,
}

class _SocketEvents {
  //Emiten al servidor para preguntar por datos
  static const String getEntregasByEnvio = 'getEntregasByEnvio';
  static const String getEntregaById = 'getEntregaById';
  static const String getAllComedores = 'getAllComedores';

  //Reciben informacion desde el server como listener
  static const String loadEntregasByEnvio = 'loadEntregasByEnvio';
  static const String loadEntregaById = '-loadEntregaById';
  static const String loadAllComedores = 'loadAllComedores';
}

mixin SocketEntregaProvider on SocketProviderBase {
  @override
  String get namespace => 'logistica/entregas';
  //Siempre existirá solo 1 elemento en esta lista.
  List<EntregaModel> entregas = [];
  List<ComedorSolidarioModel> comedores = [];
  EntregaModel? entrega;
  bool loadingEntregas = false;
  bool loadingOneEntrega = false;
  bool loadingComedores = false;

  final Map<EntregaEvent, Timer?> _timers = {};
  final Map<EntregaEvent, bool> connectionTimeouts = {
    EntregaEvent.entregasByEnvio: false,
    EntregaEvent.entregaById: false,
    //Añadir mas si creas mas evento
  };

  void connect(List<EntregaEvent> events,
      {String? idEnvio, String? idEntrega}) {
    _clearListeners(events, idEntrega: idEntrega);
    _registerListeners(events, idEntrega: idEntrega, idEnvio: idEnvio);
  }

  void disconnect(List<EntregaEvent> events,
      {String? idEnvio, String? idEntrega}) {
    _clearListeners(events, idEntrega: idEntrega);
  }

  void _registerListeners(List<EntregaEvent> events,
      {String? idEnvio, String? idEntrega}) {
    if (socket == null) return;
    for (var event in events) {
      switch (event) {
        case EntregaEvent.entregasByEnvio:
          if (idEnvio == null) {
            print('El id del envio es null');
            return;
          }
          handleSocketEvent<EntregaModel>(
            emitEvent: _SocketEvents.getEntregasByEnvio,
            loadEvent: _SocketEvents.loadEntregasByEnvio,
            dataList: entregas,
            setLoading: (loading) => loadingEntregas = loading,
            fromApi: (data) => EntregaModel.fromApi(data),
            emitPayload: {
              'idEnvio': idEnvio,
            },
          );
          break;
        case EntregaEvent.entregaById:
          if (idEntrega == null) {
            print('El id de la entrega es null');
            return;
          }
          handleSocketEvent<EntregaModel>(
            emitEvent: _SocketEvents.getEntregasByEnvio,
            loadEvent: '$idEntrega${_SocketEvents.loadEntregaById}',
            setEntity: (e) {
              entrega = e;
              notifyListeners();
            },
            setLoading: (loading) => loadingEntregas = loading,
            fromApi: (data) => EntregaModel.fromApi(data),
            emitPayload: {
              'idEntrega': idEntrega,
            },
          );
          break;
        case EntregaEvent.comedoresSolidarios:
          handleSocketEvent<ComedorSolidarioModel>(
            emitEvent: _SocketEvents.getAllComedores,
            loadEvent: _SocketEvents.loadAllComedores,
            dataList: comedores,
            setLoading: (loading) => loadingComedores = loading,
            fromApi: (data) => ComedorSolidarioModel.fromApi(data),
            emitPayload: {},
          );
          break;

        default:
          print('Evento no manejado, en LogisticaEntregasSocket: $event');
      }
    }
  }

  void _clearListeners(events, {String? idEntrega}) {
    if (socket == null) return;
    for (var event in events) {
      switch (event) {
        case EntregaEvent.entregasByEnvio:
          socket?.off(_SocketEvents.loadEntregasByEnvio);
          break;
        case EntregaEvent.entregaById:
          socket?.off('$idEntrega${_SocketEvents.loadEntregaById}');
          break;
        case EntregaEvent.comedoresSolidarios:
          socket?.off(_SocketEvents.loadAllComedores);
          break;
      }
    }
  }
}
