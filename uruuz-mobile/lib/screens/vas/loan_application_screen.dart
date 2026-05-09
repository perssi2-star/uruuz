import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class LoanApplicationScreen extends StatefulWidget {
  const LoanApplicationScreen({super.key});

  @override
  State<LoanApplicationScreen> createState() => _LoanApplicationScreenState();
}

class _LoanApplicationScreenState extends State<LoanApplicationScreen> {
  double _loanAmount = 100000;
  int _durationInWeeks = 4;
  final double _interestRate = 0.05; // 5% flat for example

  @override
  Widget build(BuildContext context) {
    double totalRepayment = _loanAmount * (1 + _interestRate);
    double weeklyPayment = totalRepayment / _durationInWeeks;

    return Scaffold(
      appBar: AppBar(title: const Text('Apply for Loan')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('How much do you need?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('UGX ${_loanAmount.toInt()}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
            Slider(
              value: _loanAmount,
              min: 50000,
              max: 500000,
              divisions: 9,
              activeColor: AppColors.primaryGreen,
              onChanged: (val) => setState(() => _loanAmount = val),
            ),
            const SizedBox(height: 32),
            const Text('Repayment Period', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [4, 8, 12].map((weeks) {
                bool isSelected = _durationInWeeks == weeks;
                return ChoiceChip(
                  label: Text('$weeks Weeks'),
                  selected: isSelected,
                  selectedColor: AppColors.primaryGreen.withOpacity(0.2),
                  onSelected: (val) => setState(() => _durationInWeeks = weeks),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _buildSummaryRow('Loan Principal', 'UGX ${_loanAmount.toInt()}'),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Total Interest (5%)', 'UGX ${(_loanAmount * _interestRate).toInt()}'),
                  const Divider(height: 32),
                  _buildSummaryRow('Total Repayment', 'UGX ${totalRepayment.toInt()}', isBold: true),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Weekly Payment', 'UGX ${weeklyPayment.toInt()}', isBold: true, color: AppColors.primaryGreen),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _showSuccessDialog,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                child: const Text('Confirm & Apply', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textGrey)),
        Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color)),
      ],
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 60),
        content: const Text('Your loan application has been submitted and is being processed by our partner, Numida.', textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Back to Dashboard'),
          ),
        ],
      ),
    );
  }
}
