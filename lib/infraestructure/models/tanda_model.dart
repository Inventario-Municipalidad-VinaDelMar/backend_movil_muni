class TandaModel {
  String id;
  int cantidadIngresada;
  int cantidadActual;
  DateTime? fechaLlegada;
  DateTime? fechaVencimiento;
  String bodega;
  String producto;
  String ubicacion;
  String categoriaId;

  TandaModel({
    required this.id,
    required this.cantidadIngresada,
    required this.cantidadActual,
    required this.fechaLlegada,
    required this.fechaVencimiento,
    required this.bodega,
    required this.producto,
    required this.ubicacion,
    required this.categoriaId,
  });
  factory TandaModel.fromApi(Map<String, dynamic> tanda) {
    return TandaModel(
      id: tanda['id'],
      cantidadIngresada: tanda['cantidadIngresada'],
      cantidadActual: tanda['cantidadActual'],
      fechaLlegada: tanda['fechaLlegada'],
      fechaVencimiento: tanda['fechaVencimiento'],
      bodega: tanda['bodega'],
      producto: tanda['producto'],
      ubicacion: tanda['ubicacion'],
      categoriaId: tanda['categoriaId'],
    );
  }
}
