import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'home_screen.dart';

class KycStatusScreen extends StatelessWidget {
  final bool success;
  final String? message;

  const KycStatusScreen({super.key, required this.success, this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              success ? Icons.check_circle_outline : Icons.error_outline,
              size: 100,
              color: success ? AppColors.primaryGreen : Colors.redAccent,
            ),
            const SizedBox(height: 32),
            Text(
              success ? 'Verification Successful!' : 'Verification Failed',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.deepCharcoal,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              success
                  ? 'Your identity has been verified. You now have full access to all Uruuz features.'
                  : message ?? 'Something went wrong during the verification process. Please try again.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  if (success) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                      (route) => false,
                    );
                  } else {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  success ? 'Continue to Dashboard' : 'Try Again',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
