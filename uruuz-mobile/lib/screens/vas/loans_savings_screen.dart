import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import 'loan_application_screen.dart';

class LoansSavingsScreen extends StatelessWidget {
  const LoansSavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loans & Savings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSavingsCard(context),
            const SizedBox(height: 30),
            const Text(
              'Quick Loans',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.deepCharcoal),
            ),
            const SizedBox(height: 16),
            _buildLoanOfferCard(context),
            const SizedBox(height: 30),
            const Text(
              'Partners',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.deepCharcoal),
            ),
            const SizedBox(height: 16),
            _buildPartnerList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primaryGreen.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Savings', style: TextStyle(color: Colors.white70, fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                child: const Text('12% APY', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('UGX 1,250,000', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primaryGreen),
                  child: const Text('Save More'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white), foregroundColor: Colors.white),
                  child: const Text('Withdraw'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoanOfferCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('You are eligible for a loan up to:', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
          const SizedBox(height: 4),
          const Text('UGX 500,000', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.deepCharcoal)),
          const SizedBox(height: 12),
          const Text('Based on your Uruuz transaction history.', style: TextStyle(color: AppColors.textGrey, fontSize: 11)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const LoanApplicationScreen()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.deepCharcoal),
              child: const Text('Apply Now', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerList() {
    final partners = [
      {'name': 'XENO Investment', 'desc': 'Money Market Fund'},
      {'name': 'Numida', 'desc': 'SME Business Loans'},
      {'name': 'M-KOPA', 'desc': 'Asset Financing'},
    ];

    return Column(
      children: partners.map((p) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(backgroundColor: Colors.grey.shade100, child: const Icon(Icons.handshake, color: AppColors.textGrey, size: 20)),
        title: Text(p['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(p['desc']!, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.info_outline, size: 16),
      )).toList(),
    );
  }
}
