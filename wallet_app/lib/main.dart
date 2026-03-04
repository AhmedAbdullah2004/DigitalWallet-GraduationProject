import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/notifications/notifications_screen.dart';

void main() => runApp(const WalletApp());

class WalletApp extends StatelessWidget {
  const WalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Wallet',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: NotificationsScreen(),
    );
  }
}