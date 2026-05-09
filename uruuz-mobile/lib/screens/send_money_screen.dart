import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'welcome_screen.dart';
import 'package:intl/intl.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  String? _senderUserId;
  
  String _amount = '0';
  Map<String, String>? _selectedRecipient;
  bool _isSubmitting = false;

  final List<Map<String, String>> _recipients = [
    {'name': 'John Musoke', 'avatar': 'JM', 'id': '00000000-0000-0000-0000-000000000002'},
    {'name': 'Sarah Namuli', 'avatar': 'SN', 'id': '00000000-0000-0000-0000-000000000003'},
    {'name': 'James Kato', 'avatar': 'JK', 'id': '00000000-0000-0000-0000-000000000004'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    _senderUserId = await _authService.getUserId();
    if (_senderUserId == null && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  void _onKeypadTap(String value) {
    setState(() {
      if (value == 'delete') {
        if (_amount.length > 1) {
          _amount = _amount.substring(0, _amount.length - 1);
        } else {
          _amount = '0';
        }
      } else if (value == '.') {
        if (!_amount.contains('.')) {
          _amount += '.';
        }
      } else {
        if (_amount == '0') {
          _amount = value;
        } else {
          _amount += value;
        }
      }
    });
  }

  Future<void> _submitTransfer() async {
    if (_senderUserId == null) return;

    if (_selectedRecipient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a recipient')),
      );
      return;
    }

    double amountDouble = double.tryParse(_amount) ?? 0;
    if (amountDouble <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _apiService.transfer(
        senderUserId: _senderUserId!,
        receiverUserId: _selectedRecipient!['id']!,
        amount: (amountDouble).toInt(), // Backend expects int64
        description: 'Transfer to ${_selectedRecipient!['name']}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transfer successful!'), backgroundColor: AppColors.primaryGreen),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Money'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAmountInput(),
                  const SizedBox(height: 30),
                  const Text(
                    'Recipients',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepCharcoal,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildRecipientList(),
                ],
              ),
            ),
          ),
          _buildNumericKeypad(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitTransfer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Continue',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Amount', style: TextStyle(color: AppColors.textGrey)),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'UGX',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _amount,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepCharcoal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecipientList() {
    return Column(
      children: _recipients.map((r) => _buildRecipientTile(r)).toList(),
    );
  }

  Widget _buildRecipientTile(Map<String, String> recipient) {
    bool isSelected = _selectedRecipient?['id'] == recipient['id'];
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: isSelected ? AppColors.primaryGreen : AppColors.primaryGreen.withOpacity(0.1),
        child: Text(
          recipient['avatar']!,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.primaryGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(recipient['name']!, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primaryGreen) : const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        setState(() {
          _selectedRecipient = recipient;
        });
      },
    );
  }

  Widget _buildNumericKeypad() {
    return Container(
      color: Colors.grey.shade50,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          _buildKeypadRow(['1', '2', '3']),
          _buildKeypadRow(['4', '5', '6']),
          _buildKeypadRow(['7', '8', '9']),
          _buildKeypadRow(['.', '0', 'delete']),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) => _buildKeypadButton(key)).toList(),
    );
  }

  Widget _buildKeypadButton(String value) {
    return InkWell(
      onTap: () => _onKeypadTap(value),
      child: Container(
        height: 60,
        width: 100,
        alignment: Alignment.center,
        child: value == 'delete'
            ? const Icon(Icons.backspace_outlined)
            : Text(
                value,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              ),
      ),
    );
  }
}
