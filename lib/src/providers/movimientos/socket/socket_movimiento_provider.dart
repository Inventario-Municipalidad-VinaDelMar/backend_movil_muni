import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/infraestructure/models/movimiento_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../../../../config/environment/environment.dart';
import '../../provider.dart';

UserProvider _userProvider = UserProvider();

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

mixin SocketMovimientoProvider on ChangeNotifier {
  //Siempre existirá solo 1 elemento en esta lista.
  List<MovimientoModel> movimientos = [];

  bool loadingMovimientos = false;

  io.Socket? _socket;
  io.Socket? get socket => _socket;

  final Map<MovimientoEvent, Timer?> _timers = {};
  final Map<MovimientoEvent, bool> connectionTimeouts = {
    MovimientoEvent.movimientosEnvio: false,
    //Añadir mas si creas mas evento
  };

  void initSocket() {
    // _updateSocket();
    _userProvider.userListener.addListener(_updateSocket);
  }

  void _updateSocket() {
    final token = _userProvider.user?.jwtToken;
    if (_socket != null && _socket!.connected) {
      _disposeSocket();
    }
    if (token == null) return;

    const namespace = 'movimientos';
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
      print('Conectado a Movimientos');
    });
    _socket!.onDisconnect((_) {
      print('Desconectado de Movimientos');
    });

    _socket?.connect();
  }

  void connect(List<MovimientoEvent> events, {String? id}) {
    print('Envio socket: $id');
    _clearListeners(events, idEnvio: id);
    _registerListeners(events, idEnvio: id);
  }

  void disconnect(List<MovimientoEvent> events, {String? id}) {
    _clearListeners(events, idEnvio: id);
    //?Probando si sirve esta linea
    movimientos.clear();
  }

  void _disposeSocket({String? id}) {
    //Esta funcion debería ejecutarse en cada cierre de sesión
    _clearAllListeners(idEnvio: id);
    _socket?.disconnect();
    _socket = null;
    movimientos.clear();
  }

  void _registerListeners(List<MovimientoEvent> events, {String? idEnvio}) {
    if (_socket == null) return;
    for (var event in events) {
      switch (event) {
        case MovimientoEvent.movimientosEnvio:
          if (idEnvio == null) {
            print('Id envio es null: $idEnvio');
            return;
          }
          _handleDataListEvent<MovimientoModel>(
            emitEvent: SocketEvents.getMovimientos,
            loadEvent: '$idEnvio${SocketEvents.loadMovimientos}',
            dataList: movimientos,
            setLoading: (loading) => loadingMovimientos = loading,
            fromApi: (data) => MovimientoModel.fromApi(data),
            emitPayload: {
              'idEnvio': idEnvio,
            },
          );
          break;
        case MovimientoEvent.movimientoOnEnvio:
          _handleNewEntityEvent<MovimientoModel>(
            newEvent: SocketEvents.newMovimientoOnEnvio,
            dataList: movimientos,
            fromApi: (data) => MovimientoModel.fromApi(data),
          );
          break;

        default:
          print('Evento no manejado, en MovimientosSocker: $event');
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
      T newEntity = fromApi(data);
      await Future.delayed(Duration(seconds: 1));
      dataList.add(newEntity);
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    });
  }

  void _clearAllListeners({String? idEnvio}) {
    if (_socket != null) {
      if (idEnvio != null) {
        _socket?.off('$idEnvio${SocketEvents.loadMovimientos}');
      }
      _socket?.off(SocketEvents.newMovimientoOnEnvio);
    }
  }

  void _clearListeners(events, {String? idEnvio}) {
    if (_socket == null) return;
    for (var event in events) {
      switch (event) {
        case MovimientoEvent.movimientosEnvio:
          _socket?.off('$idEnvio${SocketEvents.loadMovimientos}');
          break;
        case MovimientoEvent.movimientoOnEnvio:
          _socket?.off(SocketEvents.newMovimientoOnEnvio);
          break;
      }
    }
  }
}
