// دوال مساعدة
import 'package:intl/intl.dart';

/// تحويل التاريخ إلى صيغة مقروءة
String formatDate(DateTime date) {
  return DateFormat('dd/MM/yyyy').format(date);
}

/// تحويل الوقت إلى صيغة مقروءة
String formatTime(DateTime time) {
  return DateFormat('HH:mm').format(time);
}

/// تحويل التاريخ والوقت معاً
String formatDateTime(DateTime dateTime) {
  return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
}

/// التحقق من صحة البريد الإلكتروني
bool isValidEmail(String email) {
  final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  return emailRegex.hasMatch(email);
}

/// التحقق من صحة رقم الهاتف
bool isValidPhone(String phone) {
  final phoneRegex = RegExp(r'^[0-9]{10,}$');
  return phoneRegex.hasMatch(phone);
}

/// التحقق من صحة كلمة المرور
bool isValidPassword(String password) {
  return password.length >= 6;
}

/// تنسيق المبلغ المالي
String formatCurrency(double amount) {
  return '\$${amount.toStringAsFixed(2)}';
}

/// حساب الفرق بين تاريخين بالأيام
int daysBetween(DateTime from, DateTime to) {
  return to.difference(from).inDays;
}
