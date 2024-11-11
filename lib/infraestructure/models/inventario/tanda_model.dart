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
    required this.bodega,
    required this.producto,
    required this.ubicacion,
    required this.productoId,
    this.fechaVencimiento,
  });
  factory TandaModel.fromApi(Map<String, dynamic> tanda) {
    DateTime? fechaVencimiento = tanda['fechaVencimiento'] == null
        ? null
        : DateTime.parse(tanda['fechaVencimiento']);
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
  static TandaModel getNull() {
    return TandaModel(
      id: '',
      cantidadIngresada: 0,
      cantidadActual: 0,
      fechaLlegada: DateTime.now(),
      fechaVencimiento: DateTime.now(),
      bodega: '',
      producto: '',
      ubicacion: '',
      productoId: '',
    );
  }
}
