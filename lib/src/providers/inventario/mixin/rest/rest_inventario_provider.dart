import 'package:flutter/material.dart';

mixin RestInventarioProvider on ChangeNotifier {
  bool creatingTanda = false;
  bool loadingTanda = false;
  void initRest() {}

  Future<void> addTanda(Map<String, dynamic> tandaData) async {
    creatingTanda = true;
    notifyListeners();
    try {
      //await _reservasRepository.addReserva(reservaData);
    } catch (error) {
      print('Error al añadir tanda: $error');
    } finally {
      //creatingReserva = false;
      notifyListeners();
    }
  }
}
