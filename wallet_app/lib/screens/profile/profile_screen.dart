import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme.dart';
import '../../services/api_service.dart';
import 'manage_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  List<dynamic> _recentTransfers = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final profile = await ApiService.getProfile();
      final wallets = await ApiService.getMyWallets();
      final walletList = wallets['data'] ?? wallets['wallets'] ?? [];
      List<dynamic> transfers = [];
      if (walletList.isNotEmpty) {
        final tx = await ApiService.getTransferHistory(
            walletList[0]['id'].toString());
        transfers = (tx['data'] ?? tx['transfers'] ?? []).take(3).toList();
      }
      setState(() {
        _profile = profile['data'] ?? profile;
        _recentTransfers = transfers;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Are you sure?'),
        content: const Text('You will be logged out of your account.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final name = _profile?['fullName'] ?? _profile?['name'] ?? 'User';
    final email = _profile?['email'] ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Scaffold(
      appBar: AppBar(title: const Text('🚀 Profile & Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary.withOpacity(0.15),
            child: Text(initial,
                style: const TextStyle(
                    fontSize: 32,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          Text(name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(email, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Total Balance',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              Text(
                  '\$${_profile?['totalBalance']?.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
            ]),
          ),
          const SizedBox(height: 20),
          if (_recentTransfers.isNotEmpty) ...[
            const Align(
                alignment: Alignment.centerLeft,
                child: Text('Recent Transfers',
                    style:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 16))),
            const SizedBox(height: 10),
            ..._recentTransfers.map((t) => _TransferTile(transfer: t)),
            const SizedBox(height: 16),
          ],
          _MenuItem(
              icon: Icons.person_outline,
              label: 'Manage Profile',
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            ManageProfileScreen(profile: _profile!)));
              }),
          _MenuItem(
              icon: Icons.support_agent,
              label: 'Submit Complaints',
              onTap: () {}),
          _MenuItem(
              icon: Icons.phone_outlined, label: 'Contact', onTap: () {}),
          _MenuItem(
              icon: Icons.settings_outlined, label: 'Settings', onTap: () {}),
          _MenuItem(
              icon: Icons.logout,
              label: 'Log Out',
              onTap: _logout,
              isDestructive: true),
        ]),
      ),
    );
  }
}

class _TransferTile extends StatelessWidget {
  final Map<String, dynamic> transfer;
  const _TransferTile({required this.transfer});

  @override
  Widget build(BuildContext context) {
    final isCredit = (transfer['type'] ?? '') == 'credit';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        CircleAvatar(
          backgroundColor:
          (isCredit ? AppColors.success : AppColors.primary).withOpacity(0.1),
          child: Icon(isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color: isCredit ? AppColors.success : AppColors.primary,
              size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Text(transfer['description'] ?? 'Transfer',
                style: const TextStyle(fontWeight: FontWeight.w500))),
        Text(
            '${isCredit ? '+' : '-'}\$${transfer['amount']?.toStringAsFixed(2) ?? '0.00'}',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isCredit ? AppColors.success : AppColors.error)),
      ]),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuItem(
      {required this.icon,
        required this.label,
        required this.onTap,
        this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label,
            style: TextStyle(color: color, fontWeight: FontWeight.w500)),
        trailing: isDestructive
            ? null
            : const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}