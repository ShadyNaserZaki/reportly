import 'package:dio/dio.dart';
import 'package:reportly/services/storage_service.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';
import '../utils/api_endpoints.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.dio.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
              (data) => AuthResponse.fromJson(data),
        );

        if (apiResponse.success && apiResponse.data != null) {
          final authResponse = apiResponse.data!;

          // Save token and user data
          if (authResponse.token != null) {
            await StorageService.saveToken(authResponse.token!);
          }
          if (authResponse.user != null) {
            await StorageService.saveUser(authResponse.user!);
          }

          return authResponse;
        } else {
          throw Exception(apiResponse.message ?? 'Login failed');
        }
      }

      throw Exception('Login failed');
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response?.data;
        if (errorData is Map && errorData['message'] != null) {
          throw Exception(errorData['message']);
        }
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<AuthResponse> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.dio.post(
        ApiEndpoints.register,
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
              (data) => AuthResponse.fromJson(data),
        );

        if (apiResponse.success && apiResponse.data != null) {
          final authResponse = apiResponse.data!;

          // Save token and user data
          if (authResponse.token != null) {
            await StorageService.saveToken(authResponse.token!);
          }
          if (authResponse.user != null) {
            await StorageService.saveUser(authResponse.user!);
          }

          return authResponse;
        } else {
          throw Exception(apiResponse.message ?? 'Registration failed');
        }
      }

      throw Exception('Registration failed');
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response?.data;
        if (errorData is Map && errorData['message'] != null) {
          throw Exception(errorData['message']);
        }
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _apiService.dio.get(ApiEndpoints.currentUser);

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
              (data) => data,
        );

        if (apiResponse.success && apiResponse.data != null) {
          final userData = apiResponse.data as Map<String, dynamic>;
          final user = UserModel.fromJson(userData['user']);
          await StorageService.saveUser(user);
          return user;
        } else {
          throw Exception(apiResponse.message ?? 'Failed to get user');
        }
      }

      throw Exception('Failed to get user');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      }
      if (e.response != null) {
        final errorData = e.response?.data;
        if (errorData is Map && errorData['message'] != null) {
          throw Exception(errorData['message']);
        }
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<void> logout() async {
    try {
      // await _apiService.dio.post('/auth/logout');
      await StorageService.clearStorage();
    } catch (e) {
      await StorageService.clearStorage();
      rethrow;
    }
  }

  bool isLoggedIn() {
    return StorageService.getToken() != null;
  }
}