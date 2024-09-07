import 'package:flutter/material.dart';

mixin RestProductosProvider on ChangeNotifier {
  bool creatingProducto = false;
  bool loadingProducto = false;
  void initRest() {}

  Future<void> addProductos(Map<String, dynamic> productoData) async {
    creatingProducto = true;
    notifyListeners();
    try {
      //await _productosRepository.addProducto(productoData);
    } catch (error) {
      print('Error al añadir producto: $error');
    } finally {
      //creatingProducto = false;
      notifyListeners();
    }
  }
}
