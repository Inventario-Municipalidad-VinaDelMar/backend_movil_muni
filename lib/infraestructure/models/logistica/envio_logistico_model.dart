import 'package:frontend_movil_muni/infraestructure/models/planificacion/envio_model.dart';

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
    );
  }

  String getHoraCreacionFormatted() {
    final numero = int.parse(horaCreacion.split(':')[0]);
    return '${horaCreacion.split(':')[0]}:${horaCreacion.split(':')[1]} ${numero < 12 ? 'AM' : 'PM'}';
  }

  String getUltimaActualizacionFormatted() {
    final numero = int.parse(horaCreacion.split(':')[0]);
    return '${horaCreacion.split(':')[0]}:${horaCreacion.split(':')[1]} ${numero < 12 ? 'AM' : 'PM'}';
  }
}
