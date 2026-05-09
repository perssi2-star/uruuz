import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import 'generate_qr_screen.dart';
import 'merchant_settings_screen.dart';
import 'package:intl/intl.dart';

class MerchantDashboardScreen extends StatelessWidget {
  const MerchantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Merchant Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MerchantSettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSalesOverview(),
            const SizedBox(height: 30),
            _buildQuickActions(context),
            const SizedBox(height: 30),
            _buildRecentPayments(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.textGrey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Overview'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'QR Pay'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildSalesOverview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.deepCharcoal, Color(0xFF34495E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today\'s Sales',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            'UGX 450,000',
            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Transactions', '12'),
              _buildStatItem('Avg. Ticket', 'UGX 37,500'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            context,
            Icons.qr_code_scanner,
            'Generate QR',
            AppColors.primaryGreen,
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GenerateQrScreen())),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(
            context,
            Icons.account_balance,
            'Settlement',
            AppColors.ugandanGold,
            () {},
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPayments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Payments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.deepCharcoal),
            ),
            TextButton(onPressed: () {}, child: const Text('View All')),
          ],
        ),
        const SizedBox(height: 10),
        _buildPaymentTile('David Okello', 'UGX 15,000', '10:45 AM'),
        _buildPaymentTile('Brenda Namatovu', 'UGX 120,000', '09:30 AM'),
        _buildPaymentTile('Moses Kigozi', 'UGX 45,000', 'Yesterday'),
      ],
    );
  }

  Widget _buildPaymentTile(String name, String amount, String time) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
        child: Text(name[0], style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(time),
      trailing: Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
    );
  }
}
