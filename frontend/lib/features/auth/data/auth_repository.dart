import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepository(apiClient.dio, storage);
});

class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthRepository(this._dio, this._storage);

  Future<UserModel> login(String identifier, String password) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {'identifier': identifier, 'password': password},
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final user = UserModel.fromJson(data);
        if (user.token != null) {
          await _storage.write(key: 'jwt_token', value: user.token);
          await _storage.write(key: 'user_role', value: user.role);
          await _storage.write(key: 'user_name', value: user.fullName);
        }
        return user;
      } else {
        throw Exception(response.data['message'] ?? 'Error de inicio de sesión');
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Error de conexión con el servidor';
      throw Exception(msg);
    }
  }

  Future<UserModel> register({
    required String fullName,
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.register,
        data: {
          'fullName': fullName,
          'username': username,
          'email': email,
          'phoneNumber': phoneNumber,
          'password': password,
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final user = UserModel.fromJson(data);
        if (user.token != null) {
          await _storage.write(key: 'jwt_token', value: user.token);
          await _storage.write(key: 'user_role', value: user.role);
          await _storage.write(key: 'user_name', value: user.fullName);
        }
        return user;
      } else {
        throw Exception(response.data['message'] ?? 'Error en registro');
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Error de conexión con el servidor';
      throw Exception(msg);
    }
  }

  Future<UserModel?> checkAuthStatus() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null || token.isEmpty) return null;

    try {
      final response = await _dio.get(ApiEndpoints.profile);
      if (response.data['success'] == true) {
        final data = response.data['data'];
        return UserModel.fromJson(data);
      }
    } catch (_) {}
    return null;
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }
}
