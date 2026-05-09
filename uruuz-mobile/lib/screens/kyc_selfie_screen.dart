import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../services/api_service.dart';
import 'kyc_status_screen.dart';

class KycSelfieScreen extends StatefulWidget {
  const KycSelfieScreen({super.key});

  @override
  State<KycSelfieScreen> createState() => _KycSelfieScreenState();
}

class _KycSelfieScreenState extends State<KycSelfieScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;
  bool _captured = false;

  void _captureAndSubmit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Simulating image path
      await _apiService.verifyFace('00000000-0000-0000-0000-000000000001', 'temp_selfie.jpg');
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const KycStatusScreen(success: true),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => KycStatusScreen(success: false, message: e.toString()),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Step 2: Take a Selfie'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Position your face in the center',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.deepCharcoal,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryGreen, width: 2),
                ),
                child: Center(
                  child: _captured
                      ? const Icon(Icons.person, size: 200, color: Colors.white)
                      : const Icon(Icons.face_retouching_natural, size: 100, color: AppColors.textGrey),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Make sure you are in a well-lit area and your face is not covered.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGrey),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _captureAndSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Capture & Submit',
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
