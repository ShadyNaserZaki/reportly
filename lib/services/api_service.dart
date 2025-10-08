import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // 👈 علشان نستخدم kDebugMode
import 'package:reportly/services/storage_service.dart';
import '../utils/constants.dart';

class ApiService {
  late Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = StorageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // ✅ الطباعة دي هتشتغل بس في debug mode
          if (kDebugMode) {
            print('\n==================== REQUEST ====================');
            print('➡️ METHOD: ${options.method}');
            print('➡️ FULL URL: ${options.baseUrl}${options.path}');
            print('➡️ HEADERS: ${options.headers}');
            print('➡️ BODY: ${options.data}');
            print('=================================================\n');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('\n==================== RESPONSE ====================');
            print('✅ STATUS: ${response.statusCode}');
            print('➡️ URL: ${response.requestOptions.uri}');
            print('📦 DATA: ${response.data}');
            print('=================================================\n');
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          if (kDebugMode) {
            print('\n==================== ERROR ====================');
            print('❌ TYPE: ${e.type}');
            print('➡️ URL: ${e.requestOptions.uri}');
            print('➡️ MESSAGE: ${e.message}');
            if (e.response != null) {
              print('➡️ STATUS: ${e.response?.statusCode}');
              print('📦 BODY: ${e.response?.data}');
            } else {
              print('📡 No Response (maybe connection refused or timeout)');
            }

            if (e.error is SocketException) {
              print('🚫 SocketException: ${(e.error as SocketException).message}');
            }

            print('=================================================\n');
          }
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
