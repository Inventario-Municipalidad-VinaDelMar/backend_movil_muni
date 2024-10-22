import 'package:dio/dio.dart';
import 'package:frontend_movil_muni/config/environment/environment.dart';

import '../../src/providers/provider.dart';

class InventariosRepository {
  late Dio dio;

  InventariosRepository(UserProvider userProvider) {
    // Escucha cambios en el usuario y actualiza el Dio en consecuencia
    userProvider.userListener.addListener(() => _updateDio(userProvider));
    // _updateDio();
  }

  void _updateDio(UserProvider userProvider) {
    dio = Dio(
      BaseOptions(
        baseUrl: Environment.apiRestUrl,
        headers: {
          'Authorization':
              'Bearer ${userProvider.userListener.value?.jwtToken}',
        },
      ),
    )..interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
    ;
  }

  Future<void> addTanda(Map<String, dynamic> formularioTandaData) async {
    try {
      await dio.post('/inventario/tandas', data: formularioTandaData);
    } on DioException catch (error) {
      print(error.message);
      print(error.response?.data);
      print(error.type);
      throw Exception(error.response?.data['message'] ?? 'Unknown error');
    } catch (error) {
      print('Error desconocido: $error');
      throw Exception('Unknown error');
    }
  }
}
