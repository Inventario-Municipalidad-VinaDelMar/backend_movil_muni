import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/config/environment/environment.dart';
import 'package:frontend_movil_muni/infraestructure/models/logistica/entrega_model.dart';
import 'package:frontend_movil_muni/src/providers/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

UserProvider _userProvider = UserProvider();

enum EntregaEvent {
  entregasByEnvio,
  entregaById,
}

class _SocketEvents {
  //Emiten al servidor para preguntar por datos
  static const String getEntregasByEnvio = 'getEntregasByEnvio';
  static const String getEntregaById = 'getEntregaById';

  //Reciben informacion desde el server como listener
  static const String loadEntregasByEnvio = 'loadEntregasByEnvio';
  static const String loadEntregaById = '-loadEntregaById';
}

mixin SocketEnvioProvider on ChangeNotifier {
  //Siempre existirá solo 1 elemento en esta lista.
  List<EntregaModel> entregas = [];
  EntregaModel? entrega;
  bool loadingEntregas = false;
  bool loadingOneEntrega = false;

  io.Socket? _socket;
  io.Socket? get socket => _socket;

  final Map<EntregaEvent, Timer?> _timers = {};
  final Map<EntregaEvent, bool> connectionTimeouts = {
    EntregaEvent.entregasByEnvio: false,
    EntregaEvent.entregaById: false,
    //Añadir mas si creas mas evento
  };

  void initSocket() {
    _userProvider.userListener.addListener(_updateSocket);
  }

  void _updateSocket() {
    final token = _userProvider.user?.jwtToken;
    if (_socket != null && _socket!.connected) {
      _disposeSocket();
    }
    if (token == null) return;

    const namespace = 'logistica/entregas';
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
      print('Conectado a Logistica Entregas');
    });
    _socket!.onDisconnect((_) {
      print('Desconectado de Logistica Entregas');
    });

    _socket?.connect();
  }

  void connect(List<EntregaEvent> events,
      {String? idEnvio, String? idEntrega}) {
    _clearListeners(events, idEntrega: idEntrega);
    _registerListeners(events, idEntrega: idEntrega, idEnvio: idEnvio);
  }

  void disconnect(List<EntregaEvent> events,
      {String? idEnvio, String? idEntrega}) {
    _clearListeners(events, idEntrega: idEntrega);
  }

  void _disposeSocket() {
    //Esta funcion debería ejecutarse en cada cierre de sesión
    // _clearAllListeners();
    _socket?.disconnect();
    _socket = null;
    entregas.clear();
    notifyListeners();
  }

  void _registerListeners(List<EntregaEvent> events,
      {String? idEnvio, String? idEntrega}) {
    if (_socket == null) return;
    for (var event in events) {
      switch (event) {
        case EntregaEvent.entregasByEnvio:
          if (idEnvio == null) {
            print('El id del envio es null');
            return;
          }
          _handleSocketEvent<EntregaModel>(
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
          _handleSocketEvent<EntregaModel>(
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

        default:
          print('Evento no manejado, en LogisticaEntregasSocket: $event');
      }
    }
  }

  // void _handleDataListEvent<T>({
  //   required String emitEvent,
  //   required String loadEvent,
  //   required List<T> dataList,
  //   required void Function(bool) setLoading,
  //   required Map<String, dynamic> emitPayload,
  //   required T Function(Map<String, dynamic>) fromApi,
  // }) {
  //   setLoading(true);
  //   WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
  //   //?Solicitar la informacion
  //   _socket!.emit(emitEvent, emitPayload);

  //   //?Capturar informacion solicitada
  //   _socket!.on(loadEvent, (data) {
  //     List<Map<String, dynamic>> listData =
  //         List<Map<String, dynamic>>.from(data);
  //     dataList.clear();
  //     dataList.addAll(listData.map((r) => fromApi(r)).toList());
  //     setLoading(false);
  //     WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
  //   });
  // }

  // void _handleOneEntityEvent<T>({
  //   required String emitEvent,
  //   required String loadEvent,
  //   required T? entity,
  //   required void Function(bool) setLoading,
  //   required T Function(Map<String, dynamic>) fromApi,
  //   required Map<String, dynamic> emitPayload,
  // }) {
  //   setLoading(true);
  //   WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
  //   _socket!.emit(emitEvent, emitPayload);

  //   _socket!.on(loadEvent, (data) async {
  //     if (data == null) {
  //       return;
  //     }
  //     T newEntity = fromApi(data);
  //     entity = newEntity;
  //     setLoading(false);
  //     WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
  //   });
  // }
  void _handleSocketEvent<T>({
    required String emitEvent,
    required String loadEvent,
    required void Function(bool) setLoading,
    required T Function(Map<String, dynamic>) fromApi,
    required Map<String, dynamic> emitPayload,
    List<T>? dataList,
    void Function(T)? setEntity,
  }) {
    setLoading(true);
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());

    //? Solicitar la información
    _socket!.emit(emitEvent, emitPayload);

    //? Capturar información solicitada
    _socket!.on(loadEvent, (data) {
      if (data == null) {
        setLoading(false);
        return;
      }

      if (dataList != null) {
        // Modo lista
        List<Map<String, dynamic>> listData =
            List<Map<String, dynamic>>.from(data);
        dataList.clear();
        dataList.addAll(listData.map((r) => fromApi(r)).toList());
      } else if (setEntity != null) {
        // Modo entidad única
        T newEntity = fromApi(data);
        setEntity(newEntity);
      }

      setLoading(false);
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    });
  }

  void _handleNewEntityEvent<T>({
    required String newEvent,
    required List<T> dataList,
    required T Function(Map<String, dynamic>) fromApi,
  }) {
    _socket!.on(newEvent, (data) async {
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
      _socket?.off(_SocketEvents.loadEntregasByEnvio);
    }
  }

  void _clearListeners(events, {String? idEntrega}) {
    if (_socket == null) return;
    for (var event in events) {
      switch (event) {
        case EntregaEvent.entregasByEnvio:
          _socket?.off(_SocketEvents.loadEntregasByEnvio);
          break;
        case EntregaEvent.entregaById:
          _socket?.off('$idEntrega${_SocketEvents.loadEntregaById}');
          break;
      }
    }
  }
}
