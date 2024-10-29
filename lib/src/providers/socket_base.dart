import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/config/environment/environment.dart';
import 'package:frontend_movil_muni/src/providers/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

UserProvider _userProvider = UserProvider();

mixin SocketProviderBase on ChangeNotifier {
  String get namespace;

  io.Socket? _socket;
  io.Socket? get socket => _socket;

  void initSocket() {
    _userProvider.userListener.addListener(_updateSocket);
  }

  void _updateSocket() {
    final token = _userProvider.user?.jwtToken;
    if (_socket != null && _socket!.connected) {
      _disposeSocket();
    }
    if (token == null) return;

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
      print('Conectado a $namespace');
    });
    _socket!.onDisconnect((_) {
      print('Desconectado $namespace');
    });

    _socket?.connect();
  }

  void _disposeSocket() {
    _clearAllListeners();
    _socket?.disconnect();
    _socket = null;
  }

  void handleSocketEvent<T>({
    required String emitEvent,
    required String loadEvent,
    required void Function(bool) setLoading,
    required T Function(Map<String, dynamic>) fromApi,
    required Map<String, dynamic> emitPayload,
    List<T>? dataList,
    void Function(T)? setEntity,
    void Function(dynamic, T Function(Map<String, dynamic>), List<T>)?
        extraActionList,
    void Function(
      T Function(Map<String, dynamic>),
      T,
    )? extraAction,
  }) {
    setLoading(true);
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());

    //? Solicitar la información
    _socket!.emit(emitEvent, emitPayload);

    //? Capturar información solicitada
    _socket!.on(loadEvent, (data) {
      if (data == null) {
        setLoading(false);
        WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
        return;
      }

      if (dataList != null) {
        // Modo lista
        if (extraActionList != null) {
          extraActionList(data, fromApi, dataList);
        }
        List<Map<String, dynamic>> listData =
            List<Map<String, dynamic>>.from(data);
        dataList.clear();
        dataList.addAll(listData.map((r) => fromApi(r)).toList());
      } else if (setEntity != null) {
        // Modo entidad única
        T newEntity = fromApi(data);
        if (extraAction != null) {
          extraAction(fromApi, newEntity);
        }
        setEntity(newEntity);
      }

      setLoading(false);
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    });
  }

  void handleNewEntityEvent<T>({
    required String newEvent,
    required void Function(T) setEntity,
    required T Function(Map<String, dynamic>) fromApi,
    Function(T)? extraAction,
  }) {
    _socket!.on(newEvent, (data) async {
      if (data == null) {
        return;
      }
      T newEntity = fromApi(data);
      if (extraAction != null) {
        extraAction(newEntity);
      }
      setEntity(newEntity);
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    });
  }

  void _clearAllListeners() {
    _socket?.clearListeners();
  }
}
