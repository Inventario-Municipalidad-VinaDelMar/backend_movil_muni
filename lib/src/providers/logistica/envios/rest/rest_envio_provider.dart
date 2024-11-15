import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/infraestructure/repositories/logistica_repository.dart';
import 'package:frontend_movil_muni/src/providers/provider.dart';

UserProvider _userProvider = UserProvider();

mixin RestEnvioProvider on ChangeNotifier {
  late LogisticaRepository _logisticaRepository;
  bool creatingIncidente = false;
  bool proccesingDevolucion = false;

  void initRest() {
    _logisticaRepository = LogisticaRepository(_userProvider);
  }

  Future<void> addNewIncidente(Map<String, dynamic> incidenteData) async {
    creatingIncidente = true;
    notifyListeners();

    try {
      await _logisticaRepository.addNewIncidente(incidenteData);
    } catch (error) {
      print('Error al crear el incidente: $error');
      rethrow;
    } finally {
      creatingIncidente = false;
      notifyListeners();
    }
  }

  Future<void> initDevolucionProccess(
      String idEnvio, Map<String, dynamic> devolucionData) async {
    proccesingDevolucion = true;
    notifyListeners();

    try {
      await _logisticaRepository.processDevolucion(idEnvio, devolucionData);
    } catch (error) {
      print('Error al procesar la devolucion: $error');
      rethrow;
    } finally {
      proccesingDevolucion = false;
      notifyListeners();
    }
  }
}
