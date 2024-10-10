enum EnvioStatus {
  sinCargar,
  cargando,
  enEnvio,
  finalizado,
}

extension EnvioStatusExtension on EnvioStatus {
  String get displayName {
    switch (this) {
      case EnvioStatus.sinCargar:
        return 'Sin Cargar';
      case EnvioStatus.cargando:
        return 'Cargando';
      case EnvioStatus.enEnvio:
        return 'En envío';
      case EnvioStatus.finalizado:
        return 'Finalizado';
    }
  }

  // Método para convertir un String a EnvioStatus
  static EnvioStatus fromString(String status) {
    switch (status) {
      case 'Sin Cargar':
        return EnvioStatus.sinCargar;
      case 'Cargando':
        return EnvioStatus.cargando;
      case 'En envío':
        return EnvioStatus.enEnvio;
      case 'Finalizado':
        return EnvioStatus.finalizado;
      default:
        throw Exception('Status no válido');
    }
  }
}

class EnvioModel {
  String id;
  String fecha;
  String horaInicio;
  String? horaFinalizacion;
  EnvioStatus status;

  EnvioModel({
    required this.id,
    required this.fecha,
    required this.horaInicio,
    this.horaFinalizacion,
    required this.status,
  });

  factory EnvioModel.fromApi(Map<String, dynamic> envio) {
    return EnvioModel(
      id: envio['id'],
      fecha: envio['fecha'],
      horaInicio: envio['horaInicio'],
      horaFinalizacion: envio['horaFinalizacion'], // Puede ser null
      // Convertimos el string recibido en un valor de EnvioStatus
      status: EnvioStatusExtension.fromString(envio['status']),
    );
  }
}
