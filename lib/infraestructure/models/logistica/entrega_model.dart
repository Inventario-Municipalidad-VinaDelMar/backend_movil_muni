import 'package:frontend_movil_muni/infraestructure/models/auth/user_model.dart';
import 'package:frontend_movil_muni/infraestructure/models/logistica/comedor_solidario_model.dart';

class EntregaDetalle {
  int cantidadEntregada;
  String producto;
  String productoId;
  String urlImagen;

  EntregaDetalle({
    required this.producto,
    required this.productoId,
    required this.urlImagen,
    required this.cantidadEntregada,
  });

  factory EntregaDetalle.fromJson(Map<String, dynamic> json) {
    return EntregaDetalle(
      producto: json['producto'],
      productoId: json['productoId'],
      urlImagen: json['urlImagen'],
      cantidadEntregada: json['cantidadEntregada'],
    );
  }
}

class EntregaModel {
  String id;
  String fecha;
  String hora;
  String? urlActaLegal;
  UserModel copiloto;
  ComedorSolidarioModel comedorSolidario;
  List<EntregaDetalle> detallesEntrega;

  EntregaModel({
    required this.id,
    required this.fecha,
    required this.hora,
    this.urlActaLegal,
    required this.copiloto,
    required this.comedorSolidario,
    required this.detallesEntrega,
  });

  factory EntregaModel.fromApi(Map<String, dynamic> entrega) {
    return EntregaModel(
      id: entrega['id'],
      fecha: entrega['fecha'],
      hora: entrega['hora'],
      urlActaLegal: entrega['urlActaLegal'],
      copiloto: UserModel.fromApi(entrega['copiloto']),
      comedorSolidario:
          ComedorSolidarioModel.fromApi(entrega['comedorSolidario']),
      detallesEntrega: (entrega['detallesEntrega'] as List)
          .map((p) => EntregaDetalle.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}
