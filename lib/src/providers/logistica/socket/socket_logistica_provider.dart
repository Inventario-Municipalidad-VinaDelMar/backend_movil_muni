import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/config/environment/environment.dart';
import 'package:frontend_movil_muni/infraestructure/models/logistica/envio_logistico_model.dart';
import 'package:frontend_movil_muni/src/providers/provider.dart';
import 'package:frontend_movil_muni/src/utils/dates_utils.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

UserProvider _userProvider = UserProvider();

enum LogisticaEvent {
  enviosByFecha,
  newEnvio,
}

class SocketEvents {
  //Emiten al servidor para preguntar por datos
  static const String getEnviosByFecha = 'getEnviosByFecha';

  //Reciben informacion desde el server como listener
  static const String loadEnviosByFecha = 'loadEnviosByFecha';
}

mixin SocketLogisticaProvider on ChangeNotifier {
  //Siempre existirá solo 1 elemento en esta lista.
  List<EnvioLogisticoModel> enviosLogisticos = [];
  bool loadingEnvios = false;

  io.Socket? _socket;
  io.Socket? get socket => _socket;

  final Map<LogisticaEvent, Timer?> _timers = {};
  final Map<LogisticaEvent, bool> connectionTimeouts = {
    LogisticaEvent.enviosByFecha: false,
    //Añadir mas si creas mas evento
  };

  void initSocket() {
    // _updateSocket();
    print('Refrescando logistica provider');
    _userProvider.userListener.addListener(_updateSocket);
  }

  void _updateSocket() {
    final token = _userProvider.user?.jwtToken;
    if (_socket != null && _socket!.connected) {
      _disposeSocket();
    }
    if (token == null) return;

    const namespace = 'logistica/envios';
    _socket = io.io(
      '${Environment.apiSocketUrl}/$namespace',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .disableForceNew()
          .disableForceNewConnection()
          .setExtraHeaders({'authentication': token})
          .build(),
    );
    _socket!.onConnect((_) {
      print('Conectado a Logistica Envios');
    });
    _socket!.onDisconnect((_) {
      print('Desconectado de Logistica Envios');
    });

    _socket?.connect();
  }

  void connect(List<LogisticaEvent> events) {
    _clearListeners(events);
    _registerListeners(events);
  }

  void disconnect(
    List<LogisticaEvent> events,
  ) {
    _clearListeners(events);
  }

  void _disposeSocket() {
    //Esta funcion debería ejecutarse en cada cierre de sesión
    _clearAllListeners();
    _socket?.disconnect();
    _socket = null;
  }

  void _registerListeners(List<LogisticaEvent> events) {
    if (_socket == null) return;
    for (var event in events) {
      switch (event) {
        // case LogisticaEvent.loadSolicitudEnvio:
        //   _handleNewEntityEvent<SolicitudEnvioModel>(
        //     newEvent: SocketEvents.loadSolicitud,
        //     dataList: solicitudEnCurso,
        //     fromApi: (data) => SolicitudEnvioModel.fromApi(data),
        //   );
        //   break;
        case LogisticaEvent.enviosByFecha:
          _handleDataListEvent<EnvioLogisticoModel>(
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

  void _handleDataListEvent<T>({
    required String emitEvent,
    required String loadEvent,
    required List<T> dataList,
    required void Function(bool) setLoading,
    required Map<String, dynamic> emitPayload,
    required T Function(Map<String, dynamic>) fromApi,
  }) {
    setLoading(true);
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    //?Solicitar la informacion
    _socket!.emit(emitEvent, emitPayload);

    //?Capturar informacion solicitada
    _socket!.on(loadEvent, (data) {
      List<Map<String, dynamic>> listData =
          List<Map<String, dynamic>>.from(data);
      dataList.clear();
      dataList.addAll(listData.map((r) => fromApi(r)).toList());
      setLoading(false);
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    });
  }

  void _handleNewEntityEvent<T>({
    required String newEvent,
    required List<T> dataList,
    required T Function(Map<String, dynamic>) fromApi,
  }) {
    //Capturar nueva data para actualizar lista
    _socket!.on(newEvent, (data) async {
      // await Future.delayed(Duration(seconds: 1));

      if (data == null) {
        return;
      }
      T newEntity = fromApi(data);
      dataList.add(newEntity);
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    });
  }

  void _clearAllListeners() {
    if (_socket != null) {
      _socket?.off(SocketEvents.loadEnviosByFecha);
    }
  }

  void _clearListeners(events) {
    if (_socket == null) return;
    for (var event in events) {
      switch (event) {
        case LogisticaEvent.enviosByFecha:
          _socket?.off(SocketEvents.loadEnviosByFecha);
          break;
        // case PlanificacionEvent.planificacionActual:
        //   _socket?.off(SocketEvents.loadPlanificacion);
        //   break;
      }
    }
  }
}
