import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/infraestructure/models/logistica/envio_logistico_model.dart';
import 'package:frontend_movil_muni/src/providers/logistica/envios/rest/rest_envio_provider.dart';
import 'package:frontend_movil_muni/src/providers/logistica/envios/socket/socket_envio_provider.dart';
import 'package:frontend_movil_muni/src/providers/socket_base.dart';

class EnvioProvider
    with
        ChangeNotifier,
        SocketProviderBase,
        RestEnvioProvider,
        SocketEnvioProvider {
  Map<String, List<ProductoEnvio>> productosPorEnvioIncidente = {};
  bool showingListEnvio = false;

  void initialize() {
    initRest();
    initSocket();
  }

  void toggleShowListEnvios() {
    showingListEnvio = !showingListEnvio;
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
  }

  void addOneProduct(String idEnvio, ProductoEnvio prodAfectado) {
    if (!productosPorEnvioIncidente.containsKey(idEnvio)) {
      productosPorEnvioIncidente[idEnvio] = [];
    }
    productosPorEnvioIncidente[idEnvio]!.add(prodAfectado);
    notifyListeners();
  }

  void removeOneProduct(String idEnvio, ProductoEnvio prodAfectado) {
    // Verifica si el idEnvio existe en el mapa
    if (productosPorEnvioIncidente.containsKey(idEnvio)) {
      // Remueve el producto de la lista si existe
      productosPorEnvioIncidente[idEnvio]!.remove(prodAfectado);

      // Si la lista queda vacía, puedes optar por eliminar la entrada del mapa
      if (productosPorEnvioIncidente[idEnvio]!.isEmpty) {
        productosPorEnvioIncidente.remove(idEnvio);
      }

      // Notifica a los oyentes sobre el cambio
      notifyListeners();
    }
  }

  List<ProductoEnvio> getProductosPorEnvioIncidente(String idEnvio) {
    return productosPorEnvioIncidente[idEnvio] == null
        ? []
        : productosPorEnvioIncidente[idEnvio]!;
  }

  EnvioLogisticoModel? findEnvioById(String idEnvio) {
    findById(obj) => obj.id == idEnvio;
    var result = enviosLogisticos.where(findById);
    return result.isNotEmpty ? result.first : null;
  }

  EntregaEnvio? findEntregaById(String idEnvio, String idEntrega) {
    final envio = findEnvioById(idEnvio);
    if (envio == null) {
      return null;
    }
    findById(obj) => obj.id == idEntrega;
    var result = envio.entregas.where(findById);
    return result.isNotEmpty ? result.first : null;
  }

  //No se llama directamente de "envio_rest", porque se debe limpiar los productos
  Future<void> generateNewIncidente(
      Map<String, dynamic> entregaData, String idEnvio) async {
    //Esta funcion es heredada
    try {
      await addNewIncidente(entregaData).then((value) {
        productosPorEnvioIncidente.remove(idEnvio);
        notifyListeners();
      });
    } catch (e) {
      rethrow;
    }
  }
}
