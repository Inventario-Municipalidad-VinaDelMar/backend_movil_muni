import 'package:dio/dio.dart';
import 'package:frontend_movil_muni/config/environment/environment.dart';

class AuthRepository {
  final dio = Dio(
    BaseOptions(
      headers: {
        'Accept-Encoding': 'identity',
      },
      baseUrl: Environment.apiRestUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<dynamic> loginWithEmailAndPassword(
      String email, String password) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        print('response: $response');
        print('Failed to authenticate with backend');
        throw Exception('Invalid credentials');
      }
    } catch (error) {
      if (error is DioException) {
        print('DioError: $error');
        print('DioException: ${error.response?.data}');
        if (error.type == DioExceptionType.connectionTimeout) {
          throw Exception('Servidor bajo mantenimiento.');
        }
        throw Exception(error.response?.data['message'] ?? 'Unknown error');
      } else {
        print('Error desconocido: $error');
        throw Exception('App Unknown error');
      }
    }
  }

  Future<dynamic> renewToken(String idToken) async {
    try {
      final response =
          await dio.post('/auth/token/renew', data: {'idToken': idToken});
      print('Error al ejecutar renew');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        // Handle errors
        print('Failed to renew token');
        return null;
      }
    } catch (error) {
      print('Error al ejecutar renew');
      if (error is DioException) {
        // Handle Dio errors
        print(error.response?.data);
      } else {
        // Handle other errors
        print('Unknown error: $error');
      }
      return null;
    }
  }

  Future<void> signOutUser() async {
    // await GoogleSignIn().signOut();
  }
}
