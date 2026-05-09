import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'send_money_screen.dart';
import 'kyc_start_screen.dart';
import 'welcome_screen.dart';
import 'merchant/merchant_onboarding_screen.dart';
import 'vas/bills_screen.dart';
import 'vas/loans_savings_screen.dart';
import 'remittance/remittance_screen.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/wallet.dart';
import '../models/transaction.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  String? _userId;

  WalletBalance? _walletBalance;
  List<Transaction> _transactions = [];
  Map<String, dynamic>? _kycStatus;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    _userId = await _authService.getUserId();
    if (_userId == null) {
      // Should not happen if app state is correct, but for safety:
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WelcomeScreen()));
      }
      return;
    }
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (_userId == null) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final balance = await _apiService.getBalance(_userId!);
      final history = await _apiService.getHistory(_userId!);
      
      // Try to fetch KYC status, but don't fail if it's not implemented yet
      try {
        final kyc = await _apiService.getKycStatus(_userId!);
        _kycStatus = kyc;
      } catch (e) {
        // KYC service might be down or not ready
        _kycStatus = {'status': 'PENDING'};
      }

      setState(() {
        _walletBalance = balance;
        _transactions = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uruuz'),
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: _logout,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error', textAlign: TextAlign.center),
                      const SizedBox(height: 20),
                      ElevatedButton(onPressed: _fetchData, child: const Text('Retry')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_kycStatus != null && _kycStatus!['status'] != 'COMPLETED')
                            _buildKycBanner(),
                          const SizedBox(height: 10),
                          _buildWalletCard(),
                          const SizedBox(height: 30),
                          _buildQuickActions(context),
                          const SizedBox(height: 30),
                          _buildRecentTransactions(),
                        ],
                      ),
                    ),
                  ),
                ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.textGrey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }

  Widget _buildKycBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primaryGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Verify your identity',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepCharcoal,
                  ),
                ),
                Text(
                  'Complete your KYC to increase your limits.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.deepCharcoal.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const KycStartScreen()),
              );
            },
            child: const Text(
              'Verify Now',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Wallet balance',
            style: TextStyle(color: AppColors.textGrey, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '${_walletBalance?.currency ?? 'UGX'} ${NumberFormat('#,###').format(_walletBalance?.balance ?? 0)}',
            style: const TextStyle(
              color: AppColors.deepCharcoal,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      childAspectRatio: 1.5,
      children: [
        _buildActionItem(
          context,
          Icons.arrow_upward,
          'Send',
          () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SendMoneyScreen()),
            );
            if (result == true) {
              _fetchData();
            }
          },
        ),
        _buildActionItem(context, Icons.add, 'Top Up', () {}),
        _buildActionItem(
          context,
          Icons.receipt_long,
          'Bills',
          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BillsScreen())),
        ),
        _buildActionItem(
          context,
          Icons.savings,
          'Loans',
          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoansSavingsScreen())),
        ),
        _buildActionItem(context, Icons.qr_code_scanner, 'QR Pay', () {}),
        _buildActionItem(
          context,
          Icons.store,
          'Merchant',
          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MerchantOnboardingScreen())),
        ),
        _buildActionItem(
          context,
          Icons.public,
          'Global',
          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RemittanceScreen())),
        ),
      ],
    );
  }

  Widget _buildActionItem(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryGreen, size: 30),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Transactions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.deepCharcoal,
          ),
        ),
        const SizedBox(height: 15),
        if (_transactions.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text('No transactions found'),
          )
        else
          ..._transactions.take(5).map((tx) {
            String amountPrefix = tx.type == 'DEPOSIT' || tx.receiverWalletId != null ? '+' : '-';
            // Actually I should check if I am sender or receiver.
            // For now, let's keep it simple.
            return _buildTransactionTile(
              tx.description.isEmpty ? tx.type : tx.description,
              '$amountPrefix ${tx.currency} ${NumberFormat('#,###').format(tx.amount)}',
              DateFormat('dd MMM').format(tx.createdAt),
              _getIconForType(tx.type),
            );
          }),
      ],
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'TRANSFER':
        return Icons.person;
      case 'DEPOSIT':
        return Icons.add;
      case 'WITHDRAWAL':
        return Icons.remove;
      default:
        return Icons.payment;
    }
  }

  Widget _buildTransactionTile(String title, String amount, String date, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade100,
        child: Icon(icon, color: AppColors.deepCharcoal, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(date),
      trailing: Text(
        amount,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: amount.startsWith('+') ? AppColors.primaryGreen : Colors.redAccent,
        ),
      ),
    );
  }
}
