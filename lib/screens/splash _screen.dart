import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skill_swap/providers/auth_provider.dart';
import 'package:skill_swap/screens/auth/login_screen.dart';
import 'package:skill_swap/screens/home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      // Auto login
      final isLoggedIn = await auth.tryAutoLogin();

      if (!mounted) return;

      // تحقق من وجود توكن صريح
      if (isLoggedIn && auth.user?.token != null && auth.user!.token!.isNotEmpty) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      // fallback في حال خطأ
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
