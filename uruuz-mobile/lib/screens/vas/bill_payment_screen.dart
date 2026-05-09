import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class BillPaymentScreen extends StatefulWidget {
  final String billerName;
  const BillPaymentScreen({super.key, required this.billerName});

  @override
  State<BillPaymentScreen> createState() => _BillPaymentScreenState();
}

class _BillPaymentScreenState extends State<BillPaymentScreen> {
  final _accountController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isValidated = false;
  bool _isLoading = false;
  String? _customerName;

  void _validateAccount() async {
    setState(() => _isLoading = true);
    // Simulate API validation call to aggregator (Interswitch/PayWay)
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
      _isValidated = true;
      _customerName = "JOHN DOE MUSOKE"; // Mock validated name
    });
  }

  void _payBill() async {
    setState(() => _isLoading = true);
    // Simulate Advice (Payment) API call
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment Successful!'), backgroundColor: AppColors.primaryGreen),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.billerName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter details for ${widget.billerName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _accountController,
              decoration: const InputDecoration(
                labelText: 'Meter / Account Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            if (_isValidated) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: AppColors.primaryGreen),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Customer Name', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
                        Text(_customerName!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount (UGX)',
                  border: OutlineInputBorder(),
                  prefixText: 'UGX ',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : (_isValidated ? _payBill : _validateAccount),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_isValidated ? 'Pay Now' : 'Validate Account', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
