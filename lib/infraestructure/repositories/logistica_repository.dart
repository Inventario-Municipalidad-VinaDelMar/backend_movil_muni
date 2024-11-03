import 'package:dio/dio.dart';
import 'package:frontend_movil_muni/config/environment/environment.dart';
import 'package:frontend_movil_muni/src/providers/provider.dart';
import 'package:http_parser/http_parser.dart';

class LogisticaRepository {
  late Dio dio;

  LogisticaRepository(UserProvider userProvider) {
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

  Future<void> addNewEntrega(Map<String, dynamic> dataEntrega) async {
    try {
      await dio.post('/entregas', data: dataEntrega);
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

  Future<void> uploadDocument(Map<String, dynamic> dataEntrega) async {
    try {
      final String extension = dataEntrega['fileName']
          .split('.')
          .last
          .toLowerCase(); // Obtener la extensión del archivo

      MediaType mediaType;
      switch (extension) {
        case 'jpg':
          mediaType = MediaType('image', 'jpeg');
          break;
        case 'jpeg':
          mediaType = MediaType('image', 'jpeg');
          break;
        case 'png':
          mediaType = MediaType('image', 'png');
          break;
        case 'pdf':
          mediaType = MediaType('application', 'pdf');
          break;
        default:
          throw Exception('Tipo de archivo no soportado: $extension');
      }
      final file = await MultipartFile.fromFile(
        dataEntrega['path'],
        filename: dataEntrega['fileName'],
        contentType: mediaType,
      );

      final formData = FormData.fromMap({
        "file": file, // archivo que vas a subir
        "idEntrega": dataEntrega['idEntrega'] // el id que requiere el endpoint
      });

      final response = await dio.post(
        "/entregas/upload", // URL del endpoint
        data: formData,
        options: Options(headers: {"Content-Type": "multipart/form-data"}),
      );
      print("Respuesta del servidor: ${response.data}");
      //# await dio.post('/entregas/upload', data: dataEntrega);
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
