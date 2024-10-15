class TandaModel {
  String id;
  int cantidadIngresada;
  int cantidadActual;
  DateTime? fechaLlegada;
  DateTime? fechaVencimiento;
  String bodega;
  String ubicacion;
  String producto;
  String productoId;

  TandaModel({
    required this.id,
    required this.cantidadIngresada,
    required this.cantidadActual,
    required this.fechaLlegada,
    required this.fechaVencimiento,
    required this.bodega,
    required this.producto,
    required this.ubicacion,
    required this.productoId,
  });
  factory TandaModel.fromApi(Map<String, dynamic> tanda) {
    DateTime fechaVencimiento = DateTime.parse(tanda['fechaVencimiento']);
    DateTime fechaLlegada = DateTime.parse(tanda['fechaLlegada']);
    return TandaModel(
      id: tanda['id'],
      cantidadIngresada: tanda['cantidadIngresada'],
      cantidadActual: tanda['cantidadActual'],
      fechaLlegada: fechaLlegada,
      fechaVencimiento: fechaVencimiento,
      bodega: tanda['bodega'],
      producto: tanda['producto'],
      ubicacion: tanda['ubicacion'],
      productoId: tanda['productoId'],
    );
  }
}
