class MovimientoModel {
  String id;
  int cantidadRetirada;
  String fecha;
  String hora;
  String producto;
  String productoId;
  String envioId;

  //TODO: Habilitar el usuario cuando haya login
  // String usuario

  MovimientoModel({
    required this.id,
    required this.cantidadRetirada,
    required this.fecha,
    required this.hora,
    required this.producto,
    required this.productoId,
    required this.envioId,
  });
  factory MovimientoModel.fromApi(Map<String, dynamic> movimiento) {
    return MovimientoModel(
      id: movimiento['id'],
      cantidadRetirada: movimiento['cantidadRetirada'],
      fecha: movimiento['fecha'],
      hora: movimiento['hora'],
      producto: movimiento['producto'],
      productoId: movimiento['productoId'],
      envioId: movimiento['envioId'],
    );
  }

  String getMedioDia() {
    final numero = int.parse(hora.split(':')[0]);
    return numero < 12 ? 'AM' : 'PM';
  }
}
