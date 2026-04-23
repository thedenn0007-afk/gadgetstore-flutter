// ============ SPLASH SCREEN ============
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../utils/app_theme.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    _init();
  }

  Future<void> _init() async {
    final auth = context.read<AuthProvider>();
    await auth.loadUser();
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => auth.isLoggedIn ? const HomeScreen() : const LoginScreen(),
    ));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D1D1F),
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.headphones, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 24),
              const Text('GadgetStore', style: TextStyle(
                color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800,
                letterSpacing: -1.5, fontFamily: 'Inter',
              )),
              const SizedBox(height: 8),
              const Text('Premium Tech. Better Life.', style: TextStyle(
                color: Color(0xFF86868B), fontSize: 16, fontFamily: 'Inter',
              )),
              const SizedBox(height: 60),
              const SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
