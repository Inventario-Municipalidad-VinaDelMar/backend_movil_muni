class UbicacionesModel {
  String id;
  String descripcion;

  UbicacionesModel({
    required this.id,
    required this.descripcion,
  });

  factory UbicacionesModel.fromApi(Map<String, dynamic> ubicacion) {
    return UbicacionesModel(
        id: ubicacion['id'], descripcion: ubicacion['descripcion']);
  }
}
