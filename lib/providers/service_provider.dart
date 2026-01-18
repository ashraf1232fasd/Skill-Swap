import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../data/services/dio_client.dart';

class ServiceProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<dynamic> _services = [];
  List<dynamic> get services => _services;

  Future<bool> createService({
    required String title,
    required String description,
    required String category,
    required String type,
    required DateTime datetime,
    required String countryCode,
    required String phone,
    int price = 60,
  }) async {
    _setLoading(true);
    
    try {
      final response = await _dioClient.dio.post('/services', data: {
        'title': title,
        'description': description,
        'category': category,
        'price': price,
        'type': type,
        'datetime': datetime.toIso8601String(),
        'countryCode': countryCode,
        'phone': phone,
      });
      
      if (response.statusCode == 201) {
        _services.insert(0, response.data);
        _setLoading(false);
        return true;
      }
      
      _setLoading(false);
      return false;

    } on DioException catch (e) {
      _setLoading(false);
      
      String errorMessage = 'حدث خطأ في الاتصال';
      
      if (e.response != null && e.response?.data != null) {
        if (e.response?.data['message'] != null) {
          errorMessage = e.response?.data['message'];
        }
      }
      
      throw errorMessage;

    } catch (e) {
      print("Error creating service: $e");
      _setLoading(false);
      throw 'حدث خطأ غير متوقع، حاول مرة أخرى';
    }
  }

  Future<void> fetchServices() async {
    _setLoading(true);
    try {
      final response = await _dioClient.dio.get('/services');
      _services = response.data;
      notifyListeners();
    } catch (e) {
      print("Error fetching services: $e");
    }
    _setLoading(false);
  }

  Future<bool> deleteService(String serviceId) async {
    try {
      await _dioClient.dio.delete('/services/$serviceId');
      _services.removeWhere((item) => item['_id'] == serviceId);
      notifyListeners();
      return true;
    } catch (e) {
      print("Error deleting service: $e");
      return false;
    }
  }

  void removeServiceLocally(String serviceId) {
    _services.removeWhere((item) => item['_id'] == serviceId || item['id'] == serviceId);
    notifyListeners();
  }


  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}