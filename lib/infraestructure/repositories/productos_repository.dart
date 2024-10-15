import 'package:dio/dio.dart';
import 'package:frontend_movil_muni/config/environment/environment.dart';
import 'package:frontend_movil_muni/infraestructure/models/inventario/producto_model.dart';
import 'package:frontend_movil_muni/src/providers/provider.dart';

class ProductosRepository {
  late Dio dio;

  ProductosRepository(UserProvider userProvider) {
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
    );
  }

  Future<ProductosModel?> getProductos() async {
    try {
      final response = await dio.get('/productos/');

      // return productos;
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
