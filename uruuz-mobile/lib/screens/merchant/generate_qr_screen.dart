import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class GenerateQrScreen extends StatefulWidget {
  const GenerateQrScreen({super.key});

  @override
  State<GenerateQrScreen> createState() => _GenerateQrScreenState();
}

class _GenerateQrScreenState extends State<GenerateQrScreen> {
  final _amountController = TextEditingController();
  bool _showQr = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Payment QR'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            if (!_showQr) ...[
              const Text(
                'Enter the amount to receive',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (UGX)',
                  border: OutlineInputBorder(),
                  prefixText: 'UGX ',
                ),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              const Text(
                'Or leave empty for a static QR code where the customer enters the amount.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGrey, fontSize: 13),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => setState(() => _showQr = true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Generate QR Code', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ] else ...[
              const Text(
                'Scan to Pay',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _amountController.text.isEmpty ? 'Static Merchant QR' : 'UGX ${_amountController.text}',
                style: const TextStyle(fontSize: 18, color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
                ),
                child: Column(
                  children: [
                    // Mock QR Code
                    Container(
                      width: 250,
                      height: 250,
                      color: Colors.grey.shade100,
                      child: const Icon(Icons.qr_code_2, size: 200, color: AppColors.deepCharcoal),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Uruuz Merchant ID: URZ-99821',
                      style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 16, color: AppColors.textGrey),
                  SizedBox(width: 8),
                  Text('EMVCo Compliant | Interoperable', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _showQr = false;
                    _amountController.clear();
                  }),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryGreen),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Create New', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
