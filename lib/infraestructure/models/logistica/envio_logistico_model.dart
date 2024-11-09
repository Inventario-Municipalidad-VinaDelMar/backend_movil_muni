import 'package:frontend_movil_muni/infraestructure/models/planificacion/envio_model.dart';

class IncidenteEnvio {
  String id;
  String fecha;
  String hora;
  String descripcion;
  String type;
  bool causeCloseEnvio;
  String? evidenciaFotograficaUrl;
  List<ProductoEnvio> productosAfectados;

  IncidenteEnvio({
    required this.id,
    required this.fecha,
    required this.hora,
    required this.descripcion,
    required this.type,
    required this.causeCloseEnvio,
    required this.evidenciaFotograficaUrl,
    required this.productosAfectados,
  });

  factory IncidenteEnvio.fromJson(Map<String, dynamic> json) {
    return IncidenteEnvio(
      id: json['id'],
      fecha: json['fecha'],
      hora: json['hora'],
      descripcion: json['descripcion'],
      type: json['type'],
      causeCloseEnvio: json['causeCloseEnvio'] as bool,
      evidenciaFotograficaUrl: json['evidenciaFotograficaUrl'],
      productosAfectados: (json['productosAfectados'] as List)
          .map((p) => ProductoEnvio.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  String get horaFormatted {
    return '${hora.split(':')[0]}:${hora.split(':')[1]} ${int.parse(hora.split(':')[0]) >= 12 ? 'PM' : 'AM'}';
  }

  String get fechaFormatted {
    return '${fecha.split('-')[2]}/${fecha.split('-')[1]}/${fecha.split('-')[0]}';
  }
}

class ProductoEnvio {
  String producto;
  String productoId;
  String urlImagen;
  int cantidad;

  ProductoEnvio({
    required this.producto,
    required this.productoId,
    required this.urlImagen,
    required this.cantidad,
  });

  factory ProductoEnvio.fromJson(Map<String, dynamic> json) {
    return ProductoEnvio(
      producto: json['producto'],
      productoId: json['productoId'],
      urlImagen: json['urlImagen'],
      cantidad: json['cantidad'],
    );
  }
}

class EntregaEnvio {
  String id;
  String fecha;
  String hora;
  String? urlActaLegal;
  String comedorSolidario;
  String comedorDireccion;
  int productosEntregados;
  String realizador;
  String realizadorId;

  EntregaEnvio({
    required this.id,
    required this.fecha,
    required this.hora,
    this.urlActaLegal,
    required this.comedorSolidario,
    required this.realizador,
    required this.realizadorId,
    required this.comedorDireccion,
    required this.productosEntregados,
  });

  factory EntregaEnvio.fromJson(Map<String, dynamic> json) {
    return EntregaEnvio(
      id: json['id'],
      fecha: json['fecha'],
      hora: json['hora'],
      urlActaLegal: json['url_acta_legal'],
      comedorSolidario: json['comedorSolidario'],
      realizador: json['realizador'],
      realizadorId: json['realizadorId'],
      productosEntregados: json['productosEntregados'],
      comedorDireccion: json['comedorDireccion'],
    );
  }

  String getMedioDia() {
    final numero = int.parse(hora.split(':')[0]);
    return numero < 12 ? 'AM' : 'PM';
  }
}

class EnvioLogisticoModel extends EnvioModel {
  String autorizante;
  String solicitante;
  List<ProductoEnvio> productos;
  List<EntregaEnvio> entregas;
  List<IncidenteEnvio> incidentes;

  EnvioLogisticoModel({
    required super.id,
    required super.fecha,
    required super.horaCreacion,
    required super.horaInicioEnvio,
    required super.ultimaActualizacion,
    required super.status,
    super.horaFinalizacion,
    required this.autorizante,
    required this.solicitante,
    required this.productos,
    required this.entregas,
    required this.incidentes,
  });

  factory EnvioLogisticoModel.fromApi(Map<String, dynamic> envio) {
    return EnvioLogisticoModel(
      id: envio['id'],
      fecha: envio['fecha'],
      horaCreacion: envio['horaCreacion'],
      horaInicioEnvio: envio['horaInicioEnvio'],
      ultimaActualizacion: envio['ultimaActualizacion'],
      status: EnvioStatusExtension.fromString(envio['status']),
      horaFinalizacion: envio['horaFinalizacion'],
      autorizante: envio['autorizante'],
      solicitante: envio['solicitante'],
      // solicitud: SolicitudEnvioModel.fromApi(envio['solicitud']),
      productos: (envio['productos'] as List)
          .map((p) => ProductoEnvio.fromJson(p as Map<String, dynamic>))
          .toList(),
      entregas: (envio['entregas'] as List)
          .map((p) => EntregaEnvio.fromJson(p as Map<String, dynamic>))
          .toList(),
      incidentes: (envio['incidentes'] as List)
          .map((p) => IncidenteEnvio.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  String getHoraCreacionFormatted() {
    final dateTime = DateTime.parse(horaCreacion)
        .toLocal(); // Convierte a la zona horaria local
    final hour = dateTime.hour
        .toString()
        .padLeft(2, '0'); // Mantén el formato de 24 horas
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String getHoraFinalizacionFormatted() {
    if (horaFinalizacion == null) {
      return '-';
    }
    final dateTime = DateTime.parse(horaFinalizacion!)
        .toLocal(); // Convierte a la zona horaria local
    final hour = dateTime.hour
        .toString()
        .padLeft(2, '0'); // Mantén el formato de 24 horas
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String getUltimaActualizacionFormatted() {
    final dateTime = DateTime.parse(horaCreacion)
        .toLocal(); // Convierte a la zona horaria local
    final hour = dateTime.hour
        .toString()
        .padLeft(2, '0'); // Mantén el formato de 24 horas
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
