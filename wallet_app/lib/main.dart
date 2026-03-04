import 'package:flutter/material.dart';
import 'theme.dart';

void main() => runApp(const WalletApp());

class WalletApp extends StatelessWidget {
  const WalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Wallet',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: Center(
          child: Text(
            '✅ App is working!',
            style: TextStyle(fontSize: 24, color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}