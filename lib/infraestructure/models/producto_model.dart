class ProductosModel {
  String nombre;
  String descripcion;
  String urlImagen;
  String id;

  ProductosModel({
    required this.nombre,
    required this.descripcion,
    required this.urlImagen,
    required this.id,
  });

  factory ProductosModel.fromApi(Map<String, dynamic> producto) {
    return ProductosModel(
      nombre: producto['nombre'],
      descripcion: producto['descripcion'] ?? "",
      urlImagen: producto['urlImagen'] ?? "",
      id: producto['id'],
    );
  }
}

class SelectionProductModel {
  String id;
  String nombre;

  SelectionProductModel({
    required this.id,
    required this.nombre,
  });

  factory SelectionProductModel.fromApi(
      Map<String, dynamic> selectionProducto) {
    return SelectionProductModel(
      id: selectionProducto['id'],
      nombre: selectionProducto['nombre'],
    );
  }
}
