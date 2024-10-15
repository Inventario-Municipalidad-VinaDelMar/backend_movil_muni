class BodegaModel {
  String nombre;
  String direccion;
  String nombreEncargado;
  String id;

  BodegaModel({
    required this.nombre,
    required this.direccion,
    required this.nombreEncargado,
    required this.id,
  });

  factory BodegaModel.fromApi(Map<String, dynamic> bodega) {
    return BodegaModel(
        nombre: bodega['nombre'],
        direccion: bodega['direccion'],
        nombreEncargado: bodega['nombreEncargado'],
        id: bodega['id']);
  }
}

//INFO QUE VIENE DESDE LA API PARA EL DROPDOWN
class SelectionBodegaModel {
  String id;
  String nombre;

  SelectionBodegaModel({
    required this.id,
    required this.nombre,
  });

  factory SelectionBodegaModel.fromApi(Map<String, dynamic> selectionBodega) {
    return SelectionBodegaModel(
      id: selectionBodega['id'],
      nombre: selectionBodega['nombre'],
    );
  }
}
