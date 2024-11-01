import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/infraestructure/repositories/movimiento_repository.dart';
import 'package:frontend_movil_muni/src/providers/provider.dart';

UserProvider _userProvider = UserProvider();

mixin RestMovimientoProvider on ChangeNotifier {
  late MovimientoRepository _movimientoRepository;
  bool creatingMovimiento = false;

  void initRest() {
    _movimientoRepository = MovimientoRepository(_userProvider);
  }

  Future<void> addNewMovimiento(Map<String, dynamic> movimientoData) async {
    creatingMovimiento = true;
    notifyListeners();

    try {
      //TODO: Eliminar delay en production
      await Future.delayed(const Duration(seconds: 1));

      await _movimientoRepository.newMovimiento(movimientoData);
    } catch (error) {
      print('Error crear movimiento: $error');
    } finally {
      creatingMovimiento = false;
      notifyListeners();
    }
  }
}
