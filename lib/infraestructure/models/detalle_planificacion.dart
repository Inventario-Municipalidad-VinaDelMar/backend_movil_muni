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
