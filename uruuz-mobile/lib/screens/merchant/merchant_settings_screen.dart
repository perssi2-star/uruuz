import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class MerchantSettingsScreen extends StatefulWidget {
  const MerchantSettingsScreen({super.key});

  @override
  State<MerchantSettingsScreen> createState() => _MerchantSettingsScreenState();
}

class _MerchantSettingsScreenState extends State<MerchantSettingsScreen> {
  bool _voiceNotifications = true;
  bool _instantSettlement = false;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Merchant Settings'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Payment Notifications'),
          SwitchListTile(
            title: const Text('Voice Notifications'),
            subtitle: const Text('Hear a voice alert when a payment is received'),
            value: _voiceNotifications,
            activeColor: AppColors.primaryGreen,
            onChanged: (val) => setState(() => _voiceNotifications = val),
            secondary: const Icon(Icons.record_voice_over),
          ),
          const Divider(),
          _buildSectionHeader('Settlement Settings'),
          SwitchListTile(
            title: const Text('Instant Settlement (T+0)'),
            subtitle: const Text('Move funds to your bank account immediately'),
            value: _instantSettlement,
            activeColor: AppColors.primaryGreen,
            onChanged: (val) => setState(() => _instantSettlement = val),
            secondary: const Icon(Icons.bolt),
          ),
          const Divider(),
          _buildSectionHeader('Preferences'),
          ListTile(
            title: const Text('App Language'),
            subtitle: Text(_selectedLanguage),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            leading: const Icon(Icons.language),
            onTap: _showLanguagePicker,
          ),
          const Divider(),
          _buildSectionHeader('Business Profile'),
          ListTile(
            title: const Text('Update Business Info'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            leading: const Icon(Icons.edit),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Verification Status'),
            trailing: const Text('Tier 1 Verified', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
            leading: const Icon(Icons.verified),
            onTap: () {},
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: OutlinedButton(
              onPressed: () {
                // Simulate switching back to personal mode
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                foregroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Switch to Personal Account', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textGrey, letterSpacing: 1.1),
      ),
    );
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English', 'Luganda', 'Swahili'].map((lang) {
            return ListTile(
              title: Text(lang),
              onTap: () {
                setState(() => _selectedLanguage = lang);
                Navigator.pop(context);
              },
              trailing: _selectedLanguage == lang ? const Icon(Icons.check, color: AppColors.primaryGreen) : null,
            );
          }).toList(),
        );
      },
    );
  }
}
