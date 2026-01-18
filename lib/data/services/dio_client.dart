import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';

class DioClient {
  final Dio _dio;

  DioClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: AppConstants.baseUrl,
            connectTimeout: const Duration(seconds: 30), // كان 10
            receiveTimeout: const Duration(seconds: 30), // كان 10
            headers: {'Content-Type': 'application/json'},
          ),
        ) {
    
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(AppConstants.tokenKey);
          
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          print("API Error: ${e.response?.data}");
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}