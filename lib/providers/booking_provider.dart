import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../data/services/dio_client.dart';

class BookingProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();
  
  bool _isLoading = false;
  String? _errorMessage;
  List<dynamic> _bookings = []; 

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<dynamic> get bookings => _bookings;

  // جلب جميع الحجوزات (الصادرة والواردة)
  Future<void> fetchMyBookings() async {
    _setLoading(true);
    try {
      final response = await _dioClient.dio.get('/bookings');
      _bookings = response.data;
      notifyListeners();
    } catch (e) {
      print("Error fetching bookings: $e");
    }
    _setLoading(false);
  }

  Future<bool> createBooking({
    required String serviceId,
    required DateTime date,
    required int duration,
    String? note,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _dioClient.dio.post('/bookings', data: {
        'serviceId': serviceId,
        'date': date.toIso8601String(),
        'duration': duration,
        'note': note,
      });
      _setLoading(false);
      return true;
    } on DioException catch (e) {
      _errorMessage = e.response?.data['message'] ?? 'فشل الحجز';
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> updateBookingStatus(String bookingId, String status) async {
    try {
      await _dioClient.dio.put('/bookings/$bookingId', data: {
        'status': status,
      });

      final index = _bookings.indexWhere((b) => b['_id'] == bookingId);
      if (index != -1) {
        _bookings[index]['status'] = status;
        notifyListeners();
      }
      return true;
    } catch (e) {
      print("Error updating booking: $e");
      return false;
    }
  }
}
