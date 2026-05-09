import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../services/api_service.dart';
import 'kyc_selfie_screen.dart';

class KycNinScreen extends StatefulWidget {
  const KycNinScreen({super.key});

  @override
  State<KycNinScreen> createState() => _KycNinScreenState();
}

class _KycNinScreenState extends State<KycNinScreen> {
  final TextEditingController _ninController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;

  void _validateAndSubmit() async {
    final nin = _ninController.text.trim();
    if (nin.length < 14) {
      setState(() {
        _errorMessage = 'Please enter a valid 14-character NIN';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Placeholder user ID
      await _apiService.verifyNin('00000000-0000-0000-0000-000000000001', nin);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const KycSelfieScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Step 1: Enter NIN'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your 14-character National ID Number',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.deepCharcoal,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You can find this on the front of your National ID card.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _ninController,
              maxLength: 14,
              decoration: InputDecoration(
                labelText: 'NIN Number',
                hintText: 'e.g. CM000000000000',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: _errorMessage,
                counterText: '',
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              onChanged: (_) {
                if (_errorMessage != null) {
                  setState(() => _errorMessage = null);
                }
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _validateAndSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
