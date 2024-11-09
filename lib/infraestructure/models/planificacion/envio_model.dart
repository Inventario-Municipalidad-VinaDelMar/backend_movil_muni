enum EnvioStatus {
  sinCargar,
  cargando,
  cargaCompleta,
  enEnvio,
  finalizado,
}

extension EnvioStatusExtension on EnvioStatus {
  String get displayName {
    switch (this) {
      case EnvioStatus.sinCargar:
        return 'Sin cargar';
      case EnvioStatus.cargando:
        return 'Cargando';
      case EnvioStatus.cargaCompleta:
        return 'Carga completa';
      case EnvioStatus.enEnvio:
        return 'En envio';
      case EnvioStatus.finalizado:
        return 'Finalizado';
    }
  }

  // Método para convertir un String a EnvioStatus
  static EnvioStatus fromString(String status) {
    switch (status) {
      case 'Sin cargar':
        return EnvioStatus.sinCargar;
      case 'Cargando':
        return EnvioStatus.cargando;
      case 'Carga completa':
        return EnvioStatus.cargaCompleta;
      case 'En envio':
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
  String horaCreacion;
  String? horaInicioEnvio;
  String ultimaActualizacion;
  String? horaFinalizacion;
  EnvioStatus status;

  EnvioModel({
    required this.id,
    required this.fecha,
    required this.horaCreacion,
    this.horaInicioEnvio,
    required this.ultimaActualizacion,
    this.horaFinalizacion,
    required this.status,
  });

  factory EnvioModel.fromApi(Map<String, dynamic> envio) {
    return EnvioModel(
      id: envio['id'],
      fecha: envio['fecha'],
      horaCreacion: envio['horaCreacion'],
      horaInicioEnvio: envio['horaInicioEnvio'],
      ultimaActualizacion: envio['ultimaActualizacion'],
      horaFinalizacion: envio['horaFinalizacion'], // Puede ser null
      // Convertimos el string recibido en un valor de EnvioStatus
      status: EnvioStatusExtension.fromString(envio['status']),
    );
  }

  String statusToString() {
    switch (status) {
      case EnvioStatus.sinCargar:
        return 'Sin cargar';
      case EnvioStatus.cargando:
        return 'Cargando';
      case EnvioStatus.cargaCompleta:
        return 'Carga completa';
      case EnvioStatus.enEnvio:
        return 'En envio';
      case EnvioStatus.finalizado:
        return 'Finalizado';
    }
  }
}
