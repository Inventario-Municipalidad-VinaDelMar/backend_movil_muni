import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/infraestructure/repositories/inventarios_repository.dart';

import '../../../provider.dart';

UserProvider _userProvider = UserProvider();

mixin RestInventarioProvider on ChangeNotifier {
  late InventariosRepository _inventariosRepository;
  bool creatingTanda = false;
  void initRest() {
    _inventariosRepository = InventariosRepository(_userProvider);
  }

  Future<void> addTanda(Map<String, dynamic> tandaData) async {
    creatingTanda = true;

    notifyListeners();
    try {
      //TODO: Eliminar delay en production
      await Future.delayed(const Duration(seconds: 3));
      await _inventariosRepository.addTanda(tandaData);
    } catch (error) {
      print('Error al añadir tanda: $error');
    } finally {
      creatingTanda = false;
      notifyListeners();
    }
  }
}
