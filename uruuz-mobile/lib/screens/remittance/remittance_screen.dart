import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class RemittanceScreen extends StatefulWidget {
  const RemittanceScreen({super.key});

  @override
  State<RemittanceScreen> createState() => _RemittanceScreenState();
}

class _RemittanceScreenState extends State<RemittanceScreen> {
  final _amountController = TextEditingController();
  String _selectedCurrency = 'KES';
  double _exchangeRate = 0.034; // 1 UGX to KES (Placeholder)
  double _fee = 1500.0; // Flat fee for international (Placeholder)

  final List<Map<String, String>> _currencies = [
    {'code': 'KES', 'name': 'Kenya Shilling', 'flag': '🇰🇪'},
    {'code': 'TZS', 'name': 'Tanzania Shilling', 'flag': '🇹🇿'},
    {'code': 'RWF', 'name': 'Rwanda Franc', 'flag': '🇷🇼'},
    {'code': 'GBP', 'name': 'British Pound', 'flag': '🇬🇧'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('International Transfer'),
        backgroundColor: AppColors.deepCharcoal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Send Money Abroad',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.deepCharcoal,
              ),
            ),
            const SizedBox(height: 20),
            _buildAmountInput(),
            const SizedBox(height: 20),
            _buildCurrencyPicker(),
            const SizedBox(height: 20),
            _buildCalculationBox(),
            const SizedBox(height: 30),
            _buildRecipientForm(),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => _showConfirmationDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue to Review',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('You Send (UGX)', style: TextStyle(color: AppColors.textGrey)),
        const SizedBox(height: 8),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter amount in UGX',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
          ),
          onChanged: (value) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildCurrencyPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recipient Receives', style: TextStyle(color: AppColors.textGrey)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCurrency,
              isExpanded: true,
              items: _currencies.map((c) {
                return DropdownMenuItem(
                  value: c['code'],
                  child: Text('${c['flag']} ${c['name']} (${c['code']})'),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedCurrency = val!;
                  // Update rate based on currency in a real app
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalculationBox() {
    double amount = double.tryParse(_amountController.text) ?? 0;
    double recipientGets = (amount - _fee) * _exchangeRate;
    if (recipientGets < 0) recipientGets = 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _rowItem('Exchange Rate', '1 UGX = $_exchangeRate $_selectedCurrency'),
          const Divider(),
          _rowItem('Transfer Fee', '$_fee UGX'),
          const Divider(),
          _rowItem(
            'Recipient Gets',
            '${recipientGets.toStringAsFixed(2)} $_selectedCurrency',
            isBold: true,
            color: AppColors.primaryGreen,
          ),
        ],
      ),
    );
  }

  Widget _rowItem(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.between,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textGrey)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? AppColors.textBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipientForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recipient Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Full Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            labelText: 'Account / Wallet Number',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            labelText: 'Bank / Provider Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline, size: 64, color: AppColors.ugandanGold),
              const SizedBox(height: 16),
              const Text(
                'Confirm Transfer',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _rowItem('Recipient', 'John Doe (Kenya)'),
              _rowItem('Amount to Send', '${_amountController.text} UGX'),
              _rowItem('Total Cost', '${(double.tryParse(_amountController.text) ?? 0) + _fee} UGX'),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showSuccess(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                  child: const Text('Confirm & Send', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSuccess(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transfer initiated successfully!'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }
}
