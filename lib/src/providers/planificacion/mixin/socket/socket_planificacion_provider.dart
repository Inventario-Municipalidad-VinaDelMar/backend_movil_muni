import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/config/environment/environment.dart';
import 'package:frontend_movil_muni/infraestructure/models/planificacion/detalle_planificacion.dart';
import 'package:frontend_movil_muni/infraestructure/models/planificacion/planificacion_model.dart';
import 'package:frontend_movil_muni/infraestructure/models/planificacion/solicitud_envio.dart';
import 'package:frontend_movil_muni/src/providers/provider.dart';
import 'package:frontend_movil_muni/src/utils/dates_utils.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

UserProvider _userProvider = UserProvider();

enum PlanificacionEvent { planificacionActual, loadSolicitudEnvio }

class SocketEvents {
  //Emiten al servidor para preguntar por datos
  static const String getPlanificacion = 'getPlanificacion';

  //Reciben informacion desde el server como listener
  static const String loadPlanificacion = 'loadPlanificacion';
  static const String loadSolicitud = 'loadSolicitud';
}

mixin SocketPlanificacionProvider on ChangeNotifier {
  //Siempre existirá solo 1 elemento en esta lista.
  List<PlanificacionModel> planificacionActual = [];
  List<SolicitudEnvioModel> solicitudEnCurso = [];
  bool loadingPlanificacionActual = false;

  io.Socket? _socket;
  io.Socket? get socket => _socket;

  final Map<PlanificacionEvent, Timer?> _timers = {};
  final Map<PlanificacionEvent, bool> connectionTimeouts = {
    PlanificacionEvent.planificacionActual: false,
    //Añadir mas si creas mas evento
  };

  void initSocket() {
    // _updateSocket();
    print('Refrescando planificacion provider');
    _userProvider.userListener.addListener(_updateSocket);
  }

  void _updateSocket() {
    final token = _userProvider.user?.jwtToken;
    if (_socket != null && _socket!.connected) {
      _disposeSocket();
    }
    if (token == null) return;

    const namespace = 'planificacion';
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
      print('Conectado a Planificacion');
    });
    _socket!.onDisconnect((_) {
      print('Desconectado de Planificacion');
    });

    _socket?.connect();
  }

  void connect(List<PlanificacionEvent> events) {
    _clearListeners(events);
    _registerListeners(events);
  }

  void disconnect(
    List<PlanificacionEvent> events,
  ) {
    _clearListeners(events);
  }

  void _disposeSocket() {
    //Esta funcion debería ejecutarse en cada cierre de sesión
    _clearAllListeners();
    _socket?.disconnect();
    _socket = null;
    planificacionActual.clear();
  }

  DetallePlanificacion? getOneDetallePlanificacion(String productoId) {
    final detalles = planificacionActual[0].detalles;
    DetallePlanificacion? detalle;
    // Cambiar map por forEach
    detalles.forEach((d) {
      if (d.productoId == productoId) {
        detalle = d;
      }
    });

    return detalle;
  }

  void _registerListeners(List<PlanificacionEvent> events) {
    if (_socket == null) return;
    for (var event in events) {
      switch (event) {
        case PlanificacionEvent.loadSolicitudEnvio:
          _handleNewEntityEvent<SolicitudEnvioModel>(
            newEvent: SocketEvents.loadSolicitud,
            dataList: solicitudEnCurso,
            fromApi: (data) => SolicitudEnvioModel.fromApi(data),
          );
          break;
        case PlanificacionEvent.planificacionActual:
          _handleDataListEvent<PlanificacionModel>(
            emitEvent: SocketEvents.getPlanificacion,
            loadEvent: SocketEvents.loadPlanificacion,
            dataList: planificacionActual,
            setLoading: (loading) => loadingPlanificacionActual = loading,
            fromApi: (data) => PlanificacionModel.fromApi(data),
            emitPayload: {
              'fecha': getFormattedDate(),
            },
          );
          break;

        default:
          print('Evento no manejado, en PlanificacionSocket: $event');
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
    if (emitEvent == 'getPlanificacion') {
      _socket!.on(loadEvent, (data) {
        Map<String, dynamic> dataToFormated = Map<String, dynamic>.from(data);
        dataList.clear();
        dataList.add(fromApi(dataToFormated));
        setLoading(false);
        WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
      });
      return;
    }
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
      if (newEvent == 'loadSolicitud') {
        dataList.clear();
        notifyListeners();
      }
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
      _socket?.off(SocketEvents.loadPlanificacion);
    }
    _socket?.off(SocketEvents.loadSolicitud);
  }

  void _clearListeners(events) {
    if (_socket == null) return;
    for (var event in events) {
      switch (event) {
        case PlanificacionEvent.loadSolicitudEnvio:
          _socket?.off(SocketEvents.loadSolicitud);
          break;
        case PlanificacionEvent.planificacionActual:
          _socket?.off(SocketEvents.loadPlanificacion);
          break;
      }
    }
  }
}
