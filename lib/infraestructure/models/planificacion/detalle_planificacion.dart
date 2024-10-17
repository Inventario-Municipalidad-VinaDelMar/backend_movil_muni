import 'package:frontend_movil_muni/infraestructure/models/auth/user_model.dart';

class DetallesTaken {
  String idDetalle;
  UserModel? user;

  DetallesTaken({
    required this.idDetalle,
    this.user,
  });

  factory DetallesTaken.fromApi(Map<String, dynamic> detalleTaken) {
    return DetallesTaken(
      idDetalle: detalleTaken[
          'idDetalle'], //Puede ser null, si no se ha creado el envio
      user: UserModel.fromApi(detalleTaken['user']),
    );
  }
}

class DetallePlanificacion {
  String? id;
  int cantidadPlanificada;
  String producto;
  String productoId;
  bool isComplete;
  String urlImagen;

  DetallePlanificacion({
    this.id,
    required this.cantidadPlanificada,
    required this.producto,
    required this.productoId,
    required this.isComplete,
    required this.urlImagen,
  });

  factory DetallePlanificacion.fromApi(Map<String, dynamic> detalle) {
    return DetallePlanificacion(
      id: detalle['id'], //Puede ser null, si no se ha creado el envio
      cantidadPlanificada: detalle['cantidadPlanificada'],
      producto: detalle['producto'],
      productoId: detalle['productoId'],
      isComplete: detalle['isComplete'],
      urlImagen: detalle['urlImagen'],
    );
  }
}
