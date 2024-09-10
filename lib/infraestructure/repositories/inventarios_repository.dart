import 'package:dio/dio.dart';
import 'package:frontend_movil_muni/config/environment/environment.dart';
import 'package:frontend_movil_muni/infraestructure/models/tanda_model.dart';

class InventariosRepository {
  late Dio dio;

  InventariosRepository() {
    // Escucha cambios en el usuario y actualiza el Dio en consecuencia
    // userProvider.userListener.addListener(() => _updateDio(userProvider));
    _updateDio();
  }

  void _updateDio() {
    dio = Dio(
      BaseOptions(
        baseUrl: Environment.apiRestUrl,
        headers: {
          // 'Authorization':
          //     'Bearer ${userProvider.userListener.value?.jwtToken}',
        },
      ),
    )..interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
    ;
  }

  Future<void> addTanda(Map<String, dynamic> formularioTandaData) async {
    try {
      final response =
          await dio.post('/inventario/tandas', data: formularioTandaData);
      print(response);
      // return response;
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
