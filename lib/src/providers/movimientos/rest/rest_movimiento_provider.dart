import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/infraestructure/repositories/movimiento_repository.dart';
import 'package:frontend_movil_muni/src/providers/provider.dart';

UserProvider _userProvider = UserProvider();

mixin RestMovimientoProvider on ChangeNotifier {
  late MovimientoRepository _movimientoRepository;
  bool creatingRetiro = false;
  bool creatingMerma = false;

  void initRest() {
    _movimientoRepository = MovimientoRepository(_userProvider);
  }

  Future<void> addNewRetiro(Map<String, dynamic> movimientoData) async {
    creatingRetiro = true;
    notifyListeners();

    try {
      //TODO: Eliminar delay en production
      await Future.delayed(const Duration(seconds: 1));

      await _movimientoRepository.newMovimientoRetiro(movimientoData);
    } catch (error) {
      print('Error crear movimiento de retiro: $error');
    } finally {
      creatingRetiro = false;
      notifyListeners();
    }
  }

  Future<void> addNewMerma(Map<String, dynamic> movimientoData) async {
    creatingMerma = true;
    notifyListeners();

    try {
      // throw Error();
      //TODO: Eliminar delay en production
      await Future.delayed(const Duration(seconds: 1));

      await _movimientoRepository.newMovimientoMerma(movimientoData);
    } catch (error) {
      print('Error crear movimiento de merma: $error');
      rethrow;
    } finally {
      creatingMerma = false;
      notifyListeners();
    }
  }
}
