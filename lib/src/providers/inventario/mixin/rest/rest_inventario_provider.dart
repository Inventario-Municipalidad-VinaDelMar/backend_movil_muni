import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/infraestructure/repositories/inventarios_repository.dart';

mixin RestInventarioProvider on ChangeNotifier {
  late InventariosRepository _inventariosRepository;
  bool creatingTanda = false;
  bool loadingTanda = false;
  void initRest() {
    _inventariosRepository = InventariosRepository();
  }

  Future<void> addTanda(Map<String, dynamic> tandaData) async {
    creatingTanda = true;

    notifyListeners();
    try {
      print("tandaData: ${tandaData}");
      await Future.delayed(Duration(seconds: 3));
      await _inventariosRepository.addTanda(tandaData);
    } catch (error) {
      print('Error al añadir tanda: $error');
    } finally {
      creatingTanda = false;
      notifyListeners();
    }
  }
}
