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

enum PlanificacionEvent {
  planificacionActual,
  loadSolicitudEnvio,
  detallesTakenEmit,
  detallesTakenLoad,
}

class SocketEvents {
  //Emiten al servidor para preguntar por datos
  static const String getPlanificacion = 'getPlanificacion';
  static const String setDetalleAsTaken = 'setDetalleAsTaken';

  //Reciben informacion desde el server como listener
  static const String loadPlanificacion = 'loadPlanificacion';
  static const String loadSolicitud = 'loadSolicitud';
  static const String loadDetallesTaken = 'loadDetallesTaken';
}

mixin SocketPlanificacionProvider on ChangeNotifier {
  //Siempre existirá solo 1 elemento en esta lista.
  List<PlanificacionModel> planificacionActual = [];
  List<SolicitudEnvioModel> solicitudEnCurso = [];
  List<DetallesTaken> detallesTaken = [];

  bool loadingPlanificacionActual = false;
  bool waitingTimeEnvio = false;
  bool takingDetalle = false;
  String countdownText = '';

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

  void connect(List<PlanificacionEvent> events, {String? idDetalle}) {
    _clearListeners(events);
    _registerListeners(events, idDetalle: idDetalle);
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
    detallesTaken.clear();
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

  bool detalleIsTaken(idDetalle) {
    bool taken = false;
    detallesTaken.forEach((d) {
      if (d.idDetalle == idDetalle) {
        taken = true;
      }
    });

    return taken;
  }

  void initWaitingTime() async {
    int secondsRemaining = 5; // Tiempo total en segundos
    waitingTimeEnvio = true; // Inicia la espera
    notifyListeners();

    while (secondsRemaining > 0) {
      countdownText = 'Espere $secondsRemaining segs';
      notifyListeners();
      await Future.delayed(Duration(seconds: 1));
      secondsRemaining--;
    }

    waitingTimeEnvio = false;
    countdownText = '';
    notifyListeners();
  }

  void _registerListeners(List<PlanificacionEvent> events,
      {String? idDetalle}) {
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
          final fecha = getFormattedDate();
          print('Emitiendo:${SocketEvents.getPlanificacion} con fecha $fecha');
          print(
              'Recibiendo:${SocketEvents.loadPlanificacion} con fecha $fecha');
          _handleDataListEvent<PlanificacionModel>(
            emitEvent: SocketEvents.getPlanificacion,
            loadEvent: SocketEvents.loadPlanificacion,
            dataList: planificacionActual,
            setLoading: (loading) => loadingPlanificacionActual = loading,
            fromApi: (data) => PlanificacionModel.fromApi(data),
            emitPayload: {
              'fecha': fecha,
            },
          );
          break;
        case PlanificacionEvent.detallesTakenLoad:
          _socket!.on(SocketEvents.loadDetallesTaken, (data) {
            List<Map<String, dynamic>> listData =
                List<Map<String, dynamic>>.from(data);
            detallesTaken.clear();
            detallesTaken
                .addAll(listData.map((r) => DetallesTaken.fromApi(r)).toList());
            notifyListeners();
          });

          break;
        case PlanificacionEvent.detallesTakenEmit:
          final fecha = getFormattedDate();
          _socket!.emit(SocketEvents.setDetalleAsTaken, {
            'idDetalle': idDetalle,
            'fecha': fecha,
          });
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
        final planificacion = fromApi(dataToFormated) as PlanificacionModel;
        late bool envioPrevio;
        try {
          envioPrevio = planificacion.envioIniciado == null &&
              planificacionActual[0].envioIniciado != null;
        } catch (e) {
          envioPrevio = false;
        }
        dataList.clear();
        dataList.add(fromApi(dataToFormated));
        setLoading(false);
        WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());

        if (envioPrevio) {
          initWaitingTime();
        }
      });
      return;
    }
    _socket!.on(loadEvent, (data) {
      List<Map<String, dynamic>> listData =
          List<Map<String, dynamic>>.from(data);
      dataList.clear();
      dataList.addAll(listData.map((r) => fromApi(r)).toList());
      setLoading(false);
      notifyListeners();
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
      _socket?.off(SocketEvents.loadSolicitud);
      _socket?.off(SocketEvents.loadDetallesTaken);
    }
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
        case PlanificacionEvent.detallesTakenLoad:
          detallesTaken.clear();
          _socket?.off(SocketEvents.loadDetallesTaken);
          break;
        case PlanificacionEvent.detallesTakenEmit:
          // detallesTaken.clear();
          // _socket?.off(SocketEvents.loadDetallesTaken);
          print('');
          break;
      }
    }
  }
}
