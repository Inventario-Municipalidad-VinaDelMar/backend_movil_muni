import 'package:dio/dio.dart';
import 'package:frontend_movil_muni/config/environment/environment.dart';
import 'package:frontend_movil_muni/src/providers/provider.dart';

class PlanificacionRepository {
  late Dio dio;

  PlanificacionRepository(UserProvider userProvider) {
    // Escucha cambios en el usuario y actualiza el Dio en consecuencia
    userProvider.userListener.addListener(() => _updateDio(userProvider));
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
    );
  }

  Future<void> sendSolicitudAutorizacion() async {
    try {
      await dio.post('/planificacion/sendSolicitudEnvioPlanificacion');

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

  Future<void> completeCurrentEnvio() async {
    try {
      await dio.post('/envios/completeNewEnvio');

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
