import 'package:flutter/material.dart';
import 'package:frontend_movil_muni/infraestructure/repositories/logistica_repository.dart';
import 'package:frontend_movil_muni/src/providers/provider.dart';

UserProvider _userProvider = UserProvider();

mixin RestEntregaProvider on ChangeNotifier {
  late LogisticaRepository _logisticaRepository;
  bool creatingEntrega = false;
  bool uploadingFile = false;
  // bool completingEnvio = false;

  void initRest() {
    _logisticaRepository = LogisticaRepository(_userProvider);
  }

  Future<void> addNewEntrega(Map<String, dynamic> entregaData) async {
    creatingEntrega = true;
    notifyListeners();

    try {
      await _logisticaRepository.addNewEntrega(entregaData);
      // await Future.delayed(Duration(milliseconds: 2000));
    } catch (error) {
      print('Error al crear la entrega: $error');
    } finally {
      creatingEntrega = false;
      notifyListeners();
    }
  }

  Future<void> uploadFile(Map<String, dynamic> entregaData) async {
    uploadingFile = true;
    notifyListeners();

    try {
      await _logisticaRepository.uploadDocument(entregaData);
    } catch (error) {
      print('Error subir archivo: $error');
      rethrow;
    } finally {
      uploadingFile = false;
      notifyListeners();
    }
  }
}
