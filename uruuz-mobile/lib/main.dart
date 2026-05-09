import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const UruuzApp());
}

class UruuzApp extends StatefulWidget {
  const UruuzApp({super.key});

  @override
  State<UruuzApp> createState() => _UruuzAppState();
}

class _UruuzAppState extends State<UruuzApp> {
  final _authService = AuthService();
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    final token = await _authService.getToken();
    setState(() {
      _isLoggedIn = token != null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      title: 'Uruuz',
      theme: AppTheme.lightTheme,
      home: _isLoggedIn ? const HomeScreen() : const WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
