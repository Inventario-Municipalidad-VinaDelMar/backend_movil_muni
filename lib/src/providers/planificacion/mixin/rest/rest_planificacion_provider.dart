import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/infraestructure/repositories/planificacion_repository.dart';

mixin RestPlanificacionProvider on ChangeNotifier {
  late PlanificacionRepository _planificacionRepository;
  bool creatingMovimiento = false;
  void initRest() {
    _planificacionRepository = PlanificacionRepository();
  }

  Future<void> addNewMovimiento(Map<String, dynamic> movimientoData) async {
    creatingMovimiento = true;
    notifyListeners();

    try {
      //TODO: Eliminar delay en production
      await Future.delayed(const Duration(seconds: 3));

      await _planificacionRepository.newMovimiento(movimientoData);
    } catch (error) {
      print('Error crear movimiento: $error');
    } finally {
      creatingMovimiento = false;
      notifyListeners();
    }
  }
}
