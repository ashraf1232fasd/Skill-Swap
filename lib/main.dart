
//ظل علي تعديل بسيط علىى تصميم الواجهة من ناحية ازالة الايموجي + بعض الالوان في ملف profile_screen.dart  ملاحظة يوم الجمعة الساعة 6 صباحا 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skill_swap/providers/chat_provider.dart';
import 'package:skill_swap/providers/wallet_provider.dart';
import 'package:skill_swap/screens/splash%20_screen.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/service_provider.dart'; // <--- (1) استيراد الملف
import 'screens/auth/login_screen.dart';
import 'providers/booking_provider.dart'; // (1) استيراد
void main() {
  runApp(
    MultiProvider(
     providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()), 
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skill Swap',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, 
      home: const SplashScreen(),
    );
  }
}