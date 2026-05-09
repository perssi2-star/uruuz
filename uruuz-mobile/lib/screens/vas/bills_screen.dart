import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import 'bill_payment_screen.dart';

class BillsScreen extends StatelessWidget {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay Bills'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Categories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.deepCharcoal),
            ),
            const SizedBox(height: 16),
            _buildCategoryGrid(context),
            const SizedBox(height: 32),
            const Text(
              'Popular Billers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.deepCharcoal),
            ),
            const SizedBox(height: 16),
            _buildBillerList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context) {
    final categories = [
      {'icon': Icons.bolt, 'label': 'Electricity'},
      {'icon': Icons.water_drop, 'label': 'Water'},
      {'icon': Icons.tv, 'label': 'TV'},
      {'icon': Icons.wifi, 'label': 'Internet'},
      {'icon': Icons.school, 'label': 'School Fees'},
      {'icon': Icons.account_balance, 'label': 'Taxes'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(cat['icon'] as IconData, color: AppColors.primaryGreen),
            ),
            const SizedBox(height: 8),
            Text(cat['label'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
          ],
        );
      },
    );
  }

  Widget _buildBillerList(BuildContext context) {
    final billers = [
      {'name': 'Umeme Prepaid', 'category': 'Electricity', 'logo': Icons.bolt},
      {'name': 'NWSC', 'category': 'Water', 'logo': Icons.water_drop},
      {'name': 'DSTV', 'category': 'TV', 'logo': Icons.tv},
      {'name': 'Airtel Internet', 'category': 'Internet', 'logo': Icons.wifi},
    ];

    return Column(
      children: billers.map((biller) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: Colors.grey.shade100,
            child: Icon(biller['logo'] as IconData, color: AppColors.deepCharcoal, size: 20),
          ),
          title: Text(biller['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(biller['category'] as String),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BillPaymentScreen(billerName: biller['name'] as String),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
