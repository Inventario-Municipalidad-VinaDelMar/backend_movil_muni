import 'package:dio/dio.dart';
import 'package:frontend_movil_muni/config/environment/environment.dart';

class MovimientoRepository {
  late Dio dio;

  MovimientoRepository() {
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
  }

  Future<void> newMovimiento(Map<String, dynamic> movimientoData) async {
    try {
      final response = await dio.post('/movimientos', data: movimientoData);
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
