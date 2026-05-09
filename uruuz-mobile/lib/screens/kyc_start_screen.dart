import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'kyc_nin_screen.dart';

class KycStartScreen extends StatelessWidget {
  const KycStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Identity Verification'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Icon(
              Icons.verified_user_outlined,
              size: 100,
              color: AppColors.primaryGreen,
            ),
            const SizedBox(height: 40),
            const Text(
              'Let\'s verify your identity',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.deepCharcoal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'To comply with financial regulations and secure your account, we need to verify your identity using your National ID (NIN).',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textGrey,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            _buildStep(Icons.credit_card, 'Step 1', 'Enter your National ID Number (NIN)'),
            const SizedBox(height: 16),
            _buildStep(Icons.camera_alt, 'Step 2', 'Take a quick selfie for biometric matching'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const KycNinScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Get Started',
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

  Widget _buildStep(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primaryGreen),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textGrey,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.deepCharcoal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
