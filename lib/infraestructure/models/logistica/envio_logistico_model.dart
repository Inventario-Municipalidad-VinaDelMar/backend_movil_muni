import 'package:frontend_movil_muni/infraestructure/models/planificacion/envio_model.dart';
import 'package:frontend_movil_muni/infraestructure/models/planificacion/solicitud_envio.dart';

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

class EnvioLogisticoModel extends EnvioModel {
  SolicitudEnvioModel solicitud;
  List<ProductoEnvio> productos;

  EnvioLogisticoModel({
    required super.id,
    required super.fecha,
    required super.horaInicio,
    required super.status,
    super.horaFinalizacion,
    required this.solicitud,
    required this.productos,
  });

  factory EnvioLogisticoModel.fromApi(Map<String, dynamic> envio) {
    return EnvioLogisticoModel(
      id: envio['id'],
      fecha: envio['fecha'],
      horaInicio: envio['horaInicio'],
      status: EnvioStatusExtension.fromString(envio['status']),
      horaFinalizacion: envio['horaFinalizacion'],
      solicitud: SolicitudEnvioModel.fromApi(envio['solicitud']),
      productos: (envio['productos'] as List)
          .map((p) => ProductoEnvio.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  String getHoraFormatted() {
    final numero = int.parse(horaInicio.split(':')[0]);
    return '${horaInicio.split(':')[0]}:${horaInicio.split(':')[1]} ${numero < 12 ? 'AM' : 'PM'}';
  }
}
