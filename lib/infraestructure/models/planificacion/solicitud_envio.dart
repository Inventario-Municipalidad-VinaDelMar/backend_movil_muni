import 'package:frontend_movil_muni/infraestructure/models/auth/user_model.dart';
import 'package:frontend_movil_muni/infraestructure/models/planificacion/envio_model.dart';

enum SolicitudStatus {
  pendiente,
  aceptada,
  rechaza,
  expirada,
}

extension SolicitudStatusExtension on SolicitudStatus {
  String get displayName {
    switch (this) {
      case SolicitudStatus.pendiente:
        return 'Pendiente';
      case SolicitudStatus.aceptada:
        return 'Aceptada';
      case SolicitudStatus.rechaza:
        return 'Rechazada';
      case SolicitudStatus.expirada:
        return 'Expirada';
    }
  }

  // Método para convertir un String a EnvioStatus
  static SolicitudStatus fromString(String status) {
    switch (status) {
      case 'Pendiente':
        return SolicitudStatus.pendiente;
      case 'Aceptada':
        return SolicitudStatus.aceptada;
      case 'Rechazada':
        return SolicitudStatus.rechaza;
      case 'Expirada':
        return SolicitudStatus.expirada;
      default:
        throw Exception('Status no válido');
    }
  }
}

class SolicitudEnvioModel {
  String id;
  String fechaSolicitud;
  String? horaResolucion;
  String horaSolicitud;
  SolicitudStatus status;

  UserModel solicitante;
  UserModel? administrador;
  EnvioModel? envioAsociado;

  SolicitudEnvioModel({
    required this.id,
    required this.fechaSolicitud,
    required this.horaSolicitud,
    required this.status,
    required this.solicitante,
    this.horaResolucion,
    this.administrador,
    this.envioAsociado,
  });

  factory SolicitudEnvioModel.fromApi(Map<String, dynamic> solicitud) {
    return SolicitudEnvioModel(
      id: solicitud['id'],
      fechaSolicitud: solicitud['fechaSolicitud'],
      horaResolucion: solicitud['horaResolucion'],
      horaSolicitud: solicitud['horaSolicitud'],
      status: SolicitudStatusExtension.fromString(solicitud['status']),
      solicitante: UserModel.fromApi(solicitud['solicitante']),

      //campos opcionales
      administrador: solicitud['administrador'] != null
          ? UserModel.fromApi(solicitud['administrador'])
          : null,
      envioAsociado: solicitud['envioAsociado'] != null
          ? EnvioModel.fromApi(solicitud['envioAsociado'])
          : null,
    );
  }
}
