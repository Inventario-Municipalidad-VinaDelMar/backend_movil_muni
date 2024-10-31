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
  Map<String, List<ProductoEnvio>> productosPorEnvio = {};

  void initialize() {
    initRest();
    initSocket();
  }

  void addOneProduct(String idEnvio, ProductoEnvio prodEntregado) {
    if (!productosPorEnvio.containsKey(idEnvio)) {
      productosPorEnvio[idEnvio] = [];
    }
    productosPorEnvio[idEnvio]!.add(prodEntregado);
    notifyListeners();
  }

  void removeOneProduct(String idEnvio, ProductoEnvio prodEntregado) {
    // Verifica si el idEnvio existe en el mapa
    if (productosPorEnvio.containsKey(idEnvio)) {
      // Remueve el producto de la lista si existe
      productosPorEnvio[idEnvio]!.remove(prodEntregado);

      // Si la lista queda vacía, puedes optar por eliminar la entrada del mapa
      if (productosPorEnvio[idEnvio]!.isEmpty) {
        productosPorEnvio.remove(idEnvio);
      }

      // Notifica a los oyentes sobre el cambio
      notifyListeners();
    }
  }

  List<ProductoEnvio> getProductosPorEnvio(String idEnvio) {
    return productosPorEnvio[idEnvio] == null
        ? []
        : productosPorEnvio[idEnvio]!;
  }
}
