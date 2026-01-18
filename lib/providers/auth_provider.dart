import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../core/constants.dart';
import '../data/models/user_model.dart';
import '../data/services/dio_client.dart';

class AuthProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuth => _user != null && _user!.token != null;

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString(AppConstants.tokenKey);

    if (storedToken == null || storedToken.isEmpty) {
      _user = null;
      notifyListeners();
      return false;
    }

    final userData = prefs.getString('userData');
    if (userData == null) {
      _user = null;
      notifyListeners();
      return false;
    }

    try {
      _user = User.fromJson(json.decode(userData));
      _user = _user!.copyWith(token: storedToken);

      _dioClient.dio.options.headers['Authorization'] = 'Bearer ${_user!.token}';
      notifyListeners();

      refreshUser();

      return true;
    } catch (e) {
      await logout();
      return false;
    }
  }

  
  Future<void> refreshUser() async {
    if (_user == null) return;

    try {
      final response = await _dioClient.dio.get('/users/profile');
      final currentToken = _user?.token;

      _user = User.fromJson(response.data);

      // إعادة التوكن إذا مفقود
      if (_user!.token == null && currentToken != null) {
        _user = _user!.copyWith(token: currentToken);
      }

      await _saveUserDataToPrefs();
      notifyListeners();
    } catch (e) {
      print("Failed to refresh user: $e");
    }
  }

  
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _dioClient.dio.post('/users/login', data: {
        'email': email,
        'password': password,
      });

      _user = User.fromJson(response.data);
      _dioClient.dio.options.headers['Authorization'] = 'Bearer ${_user!.token}';
      await _saveUserDataToPrefs();

      _setLoading(false);
      return true;
    } on DioException catch (e) {
      if (e.response?.headers.value('content-type')?.contains('text/html') == true) {
        _errorMessage = 'خطأ في الاتصال بالسيرفر (تأكد من العنوان)';
      } else {
        _errorMessage = e.response?.data['message'] ?? 'خطأ في البريد أو كلمة المرور';
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'حدث خطأ غير متوقع';
      _setLoading(false);
      return false;
    }
  }


  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _dioClient.dio.post('/users', data: {
        'name': name,
        'email': email,
        'password': password,
      });

      _user = User.fromJson(response.data);
      _dioClient.dio.options.headers['Authorization'] = 'Bearer ${_user!.token}';
      await _saveUserDataToPrefs();

      _setLoading(false);
      return true;
    } on DioException catch (e) {
      if (e.response?.headers.value('content-type')?.contains('text/html') == true) {
        _errorMessage = 'خطأ في الاتصال بالسيرفر';
      } else {
        _errorMessage = e.response?.data['message'] ?? 'البريد الإلكتروني مستخدم بالفعل';
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'حدث خطأ غير متوقع';
      _setLoading(false);
      return false;
    }
  }

  
  Future<void> logout() async {
    _user = null;
    _errorMessage = null;
    _dioClient.dio.options.headers.remove('Authorization');

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
    await prefs.remove(AppConstants.tokenKey);

    await prefs.reload(); 

    notifyListeners();
  }


  Future<void> _saveUserDataToPrefs() async {
    if (_user == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', json.encode(_user!.toJson()));

    if (_user!.token != null && _user!.token!.isNotEmpty) {
      await prefs.setString(AppConstants.tokenKey, _user!.token!);
    }
  }


  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

 
  void increaseLocalBalance(int amount) {
    if (_user != null) {
      _user = _user!.copyWith(
        timeBalance: _user!.timeBalance + amount,
        frozenBalance: _user!.frozenBalance > amount ? _user!.frozenBalance - amount : 0,
      );
      _saveUserDataToPrefs();
      notifyListeners();
    }
  }

  void decreaseLocalBalance(int amount) {
    if (_user != null) {
      _user = _user!.copyWith(
        timeBalance: _user!.timeBalance - amount,
        frozenBalance: _user!.frozenBalance + amount,
      );
      _saveUserDataToPrefs();
      notifyListeners();
    }
  }
}
