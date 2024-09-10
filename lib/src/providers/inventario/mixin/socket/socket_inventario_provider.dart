import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/config/environment/environment.dart';
import 'package:frontend_movil_muni/infraestructure/models/bodegas_model.dart';
import 'package:frontend_movil_muni/infraestructure/models/producto_model.dart';
import 'package:frontend_movil_muni/infraestructure/models/tanda_model.dart';
import 'package:frontend_movil_muni/infraestructure/models/ubicaciones_model.dart';

import 'package:socket_io_client/socket_io_client.dart' as io;

enum InventarioEvent {
  //tandas
  getTandas,
  getTandasByCategoria,
  newTanda,
  //productos
  getProductos,
  newProducto,
  //ubicaciones
  getUbicaciones,
  newUbicacion,
  //bodegas
  getAllBodegas,
  getUbicacionesByBodega,
}

class SocketEvents {
  //Piden una lista de tandas
  static const String getTandas = 'getTandas';
  static const String getTandasByCategoria = 'getTandasByCategoria';

  //Reciben una lista de productos
  static const String getProductos = 'getAllProducts';
  static const String loadProductos = 'loadProducts';
  static const String newProducto = 'newProducto';

  //Reciben una lista de ubicaciones
  static const String getUbicacionesByBodega = 'getUbicacionesByBodega';
  static const String loadUbicacionesByBodega = 'loadUbicacionesByBodega';

  static const String newUbicacion = 'newUbicacion';

  //BODEGA
  static const String getAllBodegas = 'getAllBodegas';

  static const String loadAllBodegas = 'loadAllBodegas';
}

mixin SocketInventarioProvider on ChangeNotifier {
  List<TandaModel> tandaByCategoria = [];
  List<SelectionProductModel> productosSelection = [];
  List<BodegaModel> bodegas = [];
  List<UbicacionesModel> ubicacion = [];

  bool loadingProductos = false;
  bool loadingBodegas = false;
  bool loadingUbicacion = false;

  Map<String, dynamic> formularioTandaData = {
    'cantidadIngresada': null,
    'fechaVencimiento': null,
    'idProducto': null,
    'idBodega': null,
    'idUbicacion': null,
    'idCategoria': null
  };

  io.Socket? _socket;
  io.Socket? get socket => _socket;

  void setFormularioTandaData(String property, dynamic value) {
    formularioTandaData[property] = value;
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
  }

  void disposeFormularioTandaData() {
    formularioTandaData = {
      'cantidadIngresada': null,
      'fechaVencimiento': null,
      'idProducto': null,
      'idBodega': null,
      'idUbicacion': null,
      'idCategoria': null
    };
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
  }

  void initSocket() {
    _updateSocket();
    // _userProvider.userListener.addListener(_updateSocket);
  }

  void _updateSocket() {
    // final token = _userProvider.user?.jwtToken;
    if (_socket != null && _socket!.connected) {
      _disposeSocket();
    }
    // if (token == null) return;

    const namespace = 'inventario';
    _socket = io.io(
      '${Environment.apiSocketUrl}/$namespace',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .disableForceNew()
          .disableForceNewConnection()
          // .setExtraHeaders({'authentication': token})
          .build(),
    );

    _socket!.onConnect((_) {
      print("Conectado al server de ivnentario");
    });
    _socket!.onDisconnect((_) {
      print("Disconectado");
    });
    _socket!.onReconnect((_) {});

    _socket?.connect();
  }

  void connect(List<InventarioEvent> events) {
    //Esta funcion debería ejecutarse cada vez que se entra a una pantalla
    _clearListeners(events);
    _registerListeners(events);
  }

  void disconnect(List<InventarioEvent> events) {
    //Esta funcion debería ejecutarse cada vez que se cierra una pantalla
    _clearListeners(events);
  }

  void _disposeSocket() {
    //Esta funcion debería ejecutarse en cada cierre de sesión
    _clearAllListeners();
    _socket?.disconnect();
    _socket = null;
    productosSelection.clear();
  }

  void _registerListeners(List<InventarioEvent> events) {
    if (_socket == null) return;
    for (var event in events) {
      switch (event) {
        case InventarioEvent.getProductos:
          _handleDataListEvent<SelectionProductModel>(
            emitEvent: SocketEvents.getProductos,
            loadEvent: SocketEvents.loadProductos,
            dataList: productosSelection,
            setLoading: (loading) => loadingProductos = loading,
            fromApi: (data) => SelectionProductModel.fromApi(data),
            emitPayload: {},
          );
          break;
        case InventarioEvent.getAllBodegas:
          _handleDataListEvent<BodegaModel>(
            emitEvent: SocketEvents.getAllBodegas,
            loadEvent: SocketEvents.loadAllBodegas,
            dataList: bodegas,
            setLoading: (loading) => loadingBodegas = loading,
            fromApi: (data) => BodegaModel.fromApi(data),
            emitPayload: {},
          );
          break;
        case InventarioEvent.getUbicaciones:
          _handleDataListEvent<UbicacionesModel>(
            emitEvent: SocketEvents.getUbicacionesByBodega,
            loadEvent: SocketEvents.loadUbicacionesByBodega,
            dataList: ubicacion,
            setLoading: (loading) => loadingUbicacion = loading,
            fromApi: (data) => UbicacionesModel.fromApi(data),
            emitPayload: {"idBodega": formularioTandaData['idBodega']},
          );
          break;

        case InventarioEvent.newProducto:
          _handleNewEntityEvent<SelectionProductModel>(
            newEvent: SocketEvents.newProducto,
            dataList: productosSelection,
            fromApi: (data) => SelectionProductModel.fromApi(data),
          );
          break;

        default:
          print('Evento no manejado: $event');
      }
    }
  }

  void _clearAllListeners() {
    if (_socket != null) {
      _socket?.off(SocketEvents.loadProductos);
      _socket?.off(SocketEvents.newProducto);
    }
  }

  void _clearListeners(events) {
    if (_socket == null) return;
    for (var event in events) {
      switch (event) {
        case InventarioEvent.getProductos:
          _socket?.off(SocketEvents.loadProductos);
          break;

        case InventarioEvent.newProducto:
          _socket?.off(SocketEvents.newProducto);

          break;
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
    _socket!.on(newEvent, (data) {
      T newEntity = fromApi(data);
      dataList.add(newEntity);
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    });
  }
}
