class ComedorSolidarioModel {
  int id;
  // String id;
  String nombre;
  String direccion;

  ComedorSolidarioModel({
    required this.id,
    required this.nombre,
    required this.direccion,
  });

  factory ComedorSolidarioModel.fromApi(Map<String, dynamic> comedor) {
    return ComedorSolidarioModel(
      id: comedor['id'],
      nombre: comedor['nombre'],
      direccion: comedor['direccion'],
    );
  }
}
