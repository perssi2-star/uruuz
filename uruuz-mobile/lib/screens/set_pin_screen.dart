import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class SetPinScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  const SetPinScreen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  });

  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  void _signUp() async {
    if (_pinController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN must be 6 digits')));
      return;
    }
    if (_pinController.text != _confirmPinController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PINs do not match')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signUp(
        firstName: widget.firstName,
        lastName: widget.lastName,
        email: widget.email,
        phone: widget.phone,
        pin: _pinController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created! Please login.'), backgroundColor: AppColors.primaryGreen),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set PIN')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Secure your account',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.deepCharcoal),
            ),
            const SizedBox(height: 8),
            const Text('Set a 6-digit PIN for transactions and login.', style: TextStyle(color: AppColors.textGrey)),
            const SizedBox(height: 32),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: const InputDecoration(labelText: 'New PIN', border: OutlineInputBorder(), counterText: ''),
              style: const TextStyle(fontSize: 24, letterSpacing: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: const InputDecoration(labelText: 'Confirm PIN', border: OutlineInputBorder(), counterText: ''),
              style: const TextStyle(fontSize: 24, letterSpacing: 16),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Create Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
