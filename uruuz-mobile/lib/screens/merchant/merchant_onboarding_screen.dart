import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import 'merchant_dashboard_screen.dart';

class MerchantOnboardingScreen extends StatefulWidget {
  const MerchantOnboardingScreen({super.key});

  @override
  State<MerchantOnboardingScreen> createState() => _MerchantOnboardingScreenState();
}

class _MerchantOnboardingScreenState extends State<MerchantOnboardingScreen> {
  int _currentTier = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Merchant Onboarding'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Merchant Tier',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.deepCharcoal),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose the account type that fits your business needs.',
              style: TextStyle(color: AppColors.textGrey),
            ),
            const SizedBox(height: 24),
            _buildTierOption(
              tier: 1,
              title: 'Tier 1: Micro-Merchant',
              subtitle: 'Market vendors, Boda Bodas, small Dukas',
              requirements: ['National ID (NIN)', 'LC1 Recommendation Letter', 'Mobile Money Number'],
            ),
            const SizedBox(height: 16),
            _buildTierOption(
              tier: 2,
              title: 'Tier 2: Formal Merchant',
              subtitle: 'Supermarkets, pharmacies, registered SMEs',
              requirements: ['Certificate of Incorporation', 'TIN from URA', 'Trading License', 'Director IDs'],
            ),
            const SizedBox(height: 40),
            _buildOnboardingForm(),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // Simulate submission and navigate to dashboard
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MerchantDashboardScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Complete Onboarding', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierOption({required int tier, required String title, required String subtitle, required List<String> requirements}) {
    bool isSelected = _currentTier == tier;
    return GestureDetector(
      onTap: () => setState(() => _currentTier = tier),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primaryGreen : Colors.grey.shade300, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(tier == 1 ? Icons.store : Icons.business, color: isSelected ? AppColors.primaryGreen : AppColors.textGrey),
                const SizedBox(width: 12),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                if (isSelected) const Icon(Icons.check_circle, color: AppColors.primaryGreen),
              ],
            ),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textGrey)),
            const SizedBox(height: 12),
            const Text('Requirements:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ...requirements.map((req) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  const Icon(Icons.small_dash, size: 12),
                  const SizedBox(width: 4),
                  Text(req, style: const TextStyle(fontSize: 12)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Business Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const TextField(
          decoration: InputDecoration(labelText: 'Business Name', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16),
        const TextField(
          decoration: InputDecoration(labelText: 'Business Category', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16),
        if (_currentTier == 1)
          const TextField(
            decoration: InputDecoration(labelText: 'NIN Number', border: OutlineInputBorder()),
          )
        else
          const TextField(
            decoration: InputDecoration(labelText: 'TIN Number', border: OutlineInputBorder()),
          ),
        const SizedBox(height: 16),
        const Text('Upload Documents', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildUploadPlaceholder('ID / Certificate'),
            const SizedBox(width: 12),
            _buildUploadPlaceholder('Proof of Address'),
          ],
        ),
      ],
    );
  }

  Widget _buildUploadPlaceholder(String label) {
    return Expanded(
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_a_photo, color: AppColors.textGrey),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textGrey)),
          ],
        ),
      ),
    );
  }
}
