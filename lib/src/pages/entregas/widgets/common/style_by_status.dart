import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/infraestructure/models/logistica/envio_logistico_model.dart';
import 'package:frontend_movil_muni/infraestructure/models/planificacion/envio_model.dart';

Map<String, dynamic> getStatusStyle(EnvioLogisticoModel envio) {
  switch (envio.status) {
    case EnvioStatus.sinCargar:
      return {
        'color': Colors.grey[300],
        'icon': Icons.hourglass_empty,
        'textColor': Colors.grey[700],
        'label': envio.statusToString(),
        'asset': 'assets/logos/cargar.gif',
      };
    case EnvioStatus.cargando:
      return {
        'color': Colors.yellow[100],
        'icon': Icons.local_shipping,
        'textColor': Colors.yellow[800],
        'label': envio.statusToString(),
        'asset': 'assets/logos/cargando.gif',
      };
    case EnvioStatus.cargaCompleta:
      return {
        'color': Colors.blue[100],
        'icon': Icons.inbox,
        'textColor': Colors.blue[800],
        'label': envio.statusToString(),
        'asset': 'assets/logos/completa3.gif',
      };
    case EnvioStatus.enEnvio:
      return {
        'color': Colors.blue[100],
        'icon': Icons.directions_car,
        'textColor': Colors.blue[800],
        'label': envio.statusToString(),
        'asset': 'assets/logos/camiones3.gif',
      };
    case EnvioStatus.finalizado:
      bool incidenteCloseEnvio = false;
      envio.incidentes.forEach((i) {
        if (i.causeCloseEnvio) {
          incidenteCloseEnvio = true;
        }
      });

      return incidenteCloseEnvio
          ? {
              'color': Colors.red[100],
              'icon': Icons.check_circle,
              'textColor': Colors.red[400],
              'label': envio.statusToString(),
              'asset': 'assets/logos/fail.gif',
            }
          : {
              'color': Colors.green[100],
              'icon': Icons.check_circle,
              'textColor': Colors.green[800],
              'label': envio.statusToString(),
              'asset': 'assets/logos/finalizado.gif',
            };
  }
}
