import 'package:flutter/foundation.dart';

class AppConstants {
  static String get baseUrl {
    if (kIsWeb) {
      // للمتصفح (Chrome) استخدم localhost
      return 'http://localhost:5000/api'; 
    } else {
      // للأندرويد (Emulator) استخدم 10.0.2.2
      return 'http://10.0.2.2:5000/api'; 
    }
  }
  
  static const String tokenKey = 'auth_token';
}