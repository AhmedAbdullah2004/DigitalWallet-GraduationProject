import 'package:flutter/material.dart';
import '../../theme.dart';

class ManageProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  const ManageProfileScreen({super.key, required this.profile});

  @override
  State<ManageProfileScreen> createState() => _ManageProfileScreenState();
}

class _ManageProfileScreenState extends State<ManageProfileScreen> {
  late final _nameController =
  TextEditingController(text: widget.profile['fullName'] ?? '');
  late final _emailController =
  TextEditingController(text: widget.profile['email'] ?? '');
  late final _phoneController =
  TextEditingController(text: widget.profile['phoneNumber'] ?? '');
  final _passwordController = TextEditingController();
  bool _isSaving = false;

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Profile updated!'),
            backgroundColor: AppColors.success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: AppColors.primary.withOpacity(0.15),
            child: Text(
              (_nameController.text.isNotEmpty
                  ? _nameController.text[0]
                  : 'U')
                  .toUpperCase(),
              style: const TextStyle(
                  fontSize: 34,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 28),
          _field('Your Name', _nameController, Icons.person_outline),
          const SizedBox(height: 14),
          _field('Email', _emailController, Icons.email_outlined,
              type: TextInputType.emailAddress),
          const SizedBox(height: 14),
          _field('Mobile Number', _phoneController, Icons.phone_outlined,
              type: TextInputType.phone),
          const SizedBox(height: 14),
          _field('Password', _passwordController, Icons.lock_outline,
              obscure: true),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
                : const Text('Save'),
          ),
        ]),
      ),
    );
  }

  Widget _field(
      String label, TextEditingController ctrl, IconData icon,
      {TextInputType type = TextInputType.text, bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: type,
          obscureText: obscure,
          decoration: InputDecoration(
              prefixIcon:
              Icon(icon, size: 20, color: AppColors.textSecondary)),
        ),
      ],
    );
  }
}