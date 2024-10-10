class ProductosModel {
  String nombre;
  String descripcion;
  String urlImagen;
  // _CategoriaProductoModel categoria; // Clase privada
  String id;

  ProductosModel({
    required this.nombre,
    required this.descripcion,
    required this.urlImagen,
    // required this.categoria,
    required this.id,
  });

  factory ProductosModel.fromApi(Map<String, dynamic> producto) {
    return ProductosModel(
      nombre: producto['nombre'],
      descripcion: producto['descripcion'] ?? "",
      urlImagen: producto['urlImagen'] ?? "",
      // categoria: _CategoriaProductoModel.fromApi(producto['categoria']),
      id: producto['id'],
    );
  }
}

// HACER PRIVADA ESTA CLASE
class _CategoriaProductoModel {
  String id;
  String nombre;
  String urlImagen;

  _CategoriaProductoModel({
    required this.id,
    required this.nombre,
    required this.urlImagen,
  });

  factory _CategoriaProductoModel.fromApi(
      Map<String, dynamic> categoriaProducto) {
    return _CategoriaProductoModel(
      id: categoriaProducto['id'],
      nombre: categoriaProducto['nombre'],
      urlImagen: categoriaProducto['urlImagen'],
    );
  }
}

class SelectionProductModel {
  String id;
  String nombre;
  // _CategoriaProductoModel categoria; // Clase privada

  SelectionProductModel({
    required this.id,
    required this.nombre,
    // required this.categoria,
  });

  factory SelectionProductModel.fromApi(
      Map<String, dynamic> selectionProducto) {
    return SelectionProductModel(
      id: selectionProducto['id'],
      nombre: selectionProducto['nombre'],
      // categoria:
      //     _CategoriaProductoModel.fromApi(selectionProducto['categoria']),
    );
  }
}
