import 'dart:convert';

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
        responseType: ResponseType.plain, // Recibe el contenido en texto plano
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (Response response, ResponseInterceptorHandler handler) {
          // Intenta decodificar el texto plano como JSON
          try {
            var decodedData = json.decode(response.data); // Decodifica el JSON
            handler.next(
              Response(
                requestOptions: response.requestOptions,
                data: decodedData, // Envía el JSON decodificado
                statusCode: response.statusCode,
                statusMessage: response.statusMessage,
              ),
            );
          } catch (e) {
            // Si no puede decodificar, pasa el texto tal cual para debuggear
            handler.next(
              Response(
                requestOptions: response.requestOptions,
                data: response.data, // Pasa los datos crudos
                statusCode: response.statusCode,
                statusMessage: response.statusMessage,
              ),
            );
          }
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

  Future<void> addNewIncidente(Map<String, dynamic> dataIncidente) async {
    try {
      MultipartFile? file;

      //Cargar una imagen, no es obligatorio, por ende file puede ser null
      if (dataIncidente['fileName'] != null) {
        final String extension =
            dataIncidente['fileName'].split('.').last.toLowerCase();

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
          default:
            throw Exception('Tipo de archivo no soportado: $extension');
        }
        file = await MultipartFile.fromFile(
          dataIncidente['path'],
          filename: dataIncidente['fileName'],
          contentType: mediaType,
        );
      }
      final formData = FormData.fromMap({
        if (file != null)
          'evidenciaFotografica': file, // Solo se añade si file no es null
        'descripcion': dataIncidente['descripcion'],
        'idEnvio': dataIncidente['idEnvio'],
        'type': dataIncidente['type'],
        'productosAfectados':
            dataIncidente['productosAfectados'] as List<dynamic>,
        'closeEnvio': dataIncidente['finishEnvio'] as bool,
      });
      await dio.post(
        '/envios/newIncidente',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
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
        'file': file, // archivo que vas a subir
        'idEntrega': dataEntrega['idEntrega'] // el id que requiere el endpoint
      });

      await dio.post(
        '/entregas/upload', // URL del endpoint
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
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
