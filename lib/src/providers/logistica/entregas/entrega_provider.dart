import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/infraestructure/models/logistica/envio_logistico_model.dart';
import 'package:frontend_movil_muni/src/providers/logistica/entregas/rest/rest_entrega_provider.dart';
import 'package:frontend_movil_muni/src/providers/logistica/entregas/socket/socket_entrega_provider.dart';
import 'package:frontend_movil_muni/src/providers/socket_base.dart';

// class ProductoEntregado extends ProductoEnvio {
//   // final
//   ProductoEntregado({
//     required super.producto,
//     required super.productoId,
//     required super.urlImagen,
//     required super.cantidad,
//   });
// }

class EntregaProvider
    with
        ChangeNotifier,
        SocketProviderBase,
        RestEntregaProvider,
        SocketEntregaProvider {
  Map<String, List<ProductoEnvio>> productosPorEnvioEntrega = {};

  void initialize() {
    initRest();
    initSocket();
  }

  void addOneProduct(String idEnvio, ProductoEnvio prodEntregado) {
    if (!productosPorEnvioEntrega.containsKey(idEnvio)) {
      productosPorEnvioEntrega[idEnvio] = [];
    }
    productosPorEnvioEntrega[idEnvio]!.add(prodEntregado);
    notifyListeners();
  }

  Future<void> generateNewEntrega(
      Map<String, dynamic> entregaData, String idEnvio) async {
    //Esta funcion es heredada
    await addNewEntrega(entregaData).then((value) {
      productosPorEnvioEntrega.remove(idEnvio);
      notifyListeners();
    });
  }

  String findIdComedorSolidario(String name) {
    String id = '';
    comedores.forEach((m) {
      if (name == m.nombre) {
        id = m.id;
      }
    });
    return id;
  }

  void removeOneProduct(String idEnvio, ProductoEnvio prodEntregado) {
    // Verifica si el idEnvio existe en el mapa
    if (productosPorEnvioEntrega.containsKey(idEnvio)) {
      // Remueve el producto de la lista si existe
      productosPorEnvioEntrega[idEnvio]!.remove(prodEntregado);

      // Si la lista queda vacía, puedes optar por eliminar la entrada del mapa
      if (productosPorEnvioEntrega[idEnvio]!.isEmpty) {
        productosPorEnvioEntrega.remove(idEnvio);
      }

      // Notifica a los oyentes sobre el cambio
      notifyListeners();
    }
  }

  List<ProductoEnvio> getProductosPorEnvioEntrega(String idEnvio) {
    return productosPorEnvioEntrega[idEnvio] == null
        ? []
        : productosPorEnvioEntrega[idEnvio]!;
  }
}
