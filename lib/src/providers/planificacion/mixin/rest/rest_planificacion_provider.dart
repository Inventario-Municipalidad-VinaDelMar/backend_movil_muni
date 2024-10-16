import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/infraestructure/repositories/planificacion_repository.dart';
import 'package:frontend_movil_muni/src/providers/provider.dart';

UserProvider _userProvider = UserProvider();

mixin RestPlanificacionProvider on ChangeNotifier {
  late PlanificacionRepository _planificacionRepository;
  bool processingSolicitud = false;
  bool completingEnvio = false;

  void initRest() {
    _planificacionRepository = PlanificacionRepository(_userProvider);
  }

  Future<void> sendSolicitudAutorizacion() async {
    processingSolicitud = true;
    notifyListeners();

    try {
      await _planificacionRepository.sendSolicitudAutorizacion();
    } catch (error) {
      print('Error al crear solicitud de autorizacion: $error');
    } finally {
      processingSolicitud = false;
      notifyListeners();
    }
  }

  Future<void> completeCurrentEnvio() async {
    completingEnvio = true;
    notifyListeners();

    try {
      await _planificacionRepository.completeCurrentEnvio();
    } catch (error) {
      print('Error al completar el envio actual: $error');
    } finally {
      completingEnvio = false;
      notifyListeners();
    }
  }
}
