import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/infraestructure/models/planificacion/detalle_planificacion.dart';
import 'package:frontend_movil_muni/infraestructure/models/planificacion/planificacion_model.dart';
import 'package:frontend_movil_muni/infraestructure/models/planificacion/solicitud_envio.dart';
import 'package:frontend_movil_muni/src/providers/socket_base.dart';
import 'package:frontend_movil_muni/src/utils/dates_utils.dart';

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

mixin SocketPlanificacionProvider on SocketProviderBase {
  @override
  String get namespace => 'planificacion';
  //Siempre existirá solo 1 elemento en esta lista.
  PlanificacionModel? planificacionActual;
  SolicitudEnvioModel? solicitudEnCurso;
  List<DetallesTaken> detallesTaken = [];

  bool loadingPlanificacionActual = false;
  bool waitingTimeEnvio = false;
  bool takingDetalle = false;
  String countdownText = '';

  final Map<PlanificacionEvent, Timer?> _timers = {};
  final Map<PlanificacionEvent, bool> connectionTimeouts = {
    PlanificacionEvent.planificacionActual: false,
    //Añadir mas si creas mas evento
  };

  void connect(List<PlanificacionEvent> events,
      {String? idDetalle,
      void Function(SolicitudEnvioModel)? onSolicitudReceived}) {
    _clearListeners(events);
    _registerListeners(
      events,
      idDetalle: idDetalle,
      onSolicitudReceived: onSolicitudReceived,
    );
  }

  void disconnect(
    List<PlanificacionEvent> events,
  ) {
    _clearListeners(events);
  }

  DetallePlanificacion? getOneDetallePlanificacion(String productoId) {
    final detalles = planificacionActual!.detalles;
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

  void _registerListeners(
    List<PlanificacionEvent> events, {
    String? idDetalle,
    void Function(SolicitudEnvioModel)? onSolicitudReceived,
  }) {
    if (socket == null) return;
    for (var event in events) {
      switch (event) {
        case PlanificacionEvent.loadSolicitudEnvio:
          handleNewEntityEvent<SolicitudEnvioModel>(
            newEvent: SocketEvents.loadSolicitud,
            setEntity: (entity) {
              solicitudEnCurso = entity;
              notifyListeners();
            },
            fromApi: (data) => SolicitudEnvioModel.fromApi(data),
            //Solo funciona para el evento "loadSolicitud"
            extraAction: (solicitud) => onSolicitudReceived!(solicitud),
          );
          break;
        case PlanificacionEvent.planificacionActual:
          final fecha = getFormattedDate();
          handleSocketEvent<PlanificacionModel>(
              emitEvent: SocketEvents.getPlanificacion,
              loadEvent: SocketEvents.loadPlanificacion,
              setLoading: (loading) => loadingPlanificacionActual = loading,
              fromApi: (data) => PlanificacionModel.fromApi(data),
              emitPayload: {
                'fecha': fecha,
              },
              setEntity: (entity) {
                planificacionActual = entity;
                notifyListeners();
              },
              extraAction: (fromApi, entity) {
                late bool envioPrevio;
                if (planificacionActual != null &&
                    entity.envioIniciado == null) {
                  envioPrevio = planificacionActual?.envioIniciado != null;
                } else {
                  envioPrevio = false;
                }
                if (envioPrevio) {
                  initWaitingTime();
                }
              });
          break;
        case PlanificacionEvent.detallesTakenLoad:
          socket!.on(SocketEvents.loadDetallesTaken, (data) {
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
          socket!.emit(SocketEvents.setDetalleAsTaken, {
            'idDetalle': idDetalle,
            'fecha': fecha,
          });
          break;

        default:
          print('Evento no manejado, en PlanificacionSocket: $event');
      }
    }
  }

  void _clearListeners(events) {
    if (socket == null) return;
    for (var event in events) {
      switch (event) {
        case PlanificacionEvent.loadSolicitudEnvio:
          socket?.off(SocketEvents.loadSolicitud);
          break;
        case PlanificacionEvent.planificacionActual:
          socket?.off(SocketEvents.loadPlanificacion);
          break;
        case PlanificacionEvent.detallesTakenLoad:
          socket?.off(SocketEvents.loadDetallesTaken);
          break;
      }
    }
  }
}
