import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:7182';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Auth
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/Auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> register(
      String name, String email, String password, String phone) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/Auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullName': name,
        'email': email,
        'password': password,
        'phoneNumber': phone,
      }),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> verifyOtp(
      String userId, String otp) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/Auth/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'otpCode': otp}),
    );
    return jsonDecode(res.body);
  }

  // Wallet
  static Future<Map<String, dynamic>> getMyWallets() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/Wallet/my-wallets'),
      headers: await _authHeaders(),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getWalletBalance(
      String walletId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/Wallet/$walletId/balance'),
      headers: await _authHeaders(),
    );
    return jsonDecode(res.body);
  }

  // Transfer
  static Future<Map<String, dynamic>> sendTransfer({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    required String otp,
    String? note,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/Transfer/send'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'fromWalletId': fromWalletId,
        'toWalletId': toWalletId,
        'amount': amount,
        'otpCode': otp,
        if (note != null) 'note': note,
      }),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getTransferHistory(
      String walletId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/Transfer/history/$walletId'),
      headers: await _authHeaders(),
    );
    return jsonDecode(res.body);
  }

  // Transactions
  static Future<Map<String, dynamic>> getTransactions(
      String walletId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/Transaction/wallet/$walletId'),
      headers: await _authHeaders(),
    );
    return jsonDecode(res.body);
  }

  // User
  static Future<Map<String, dynamic>> getProfile() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/User/profile'),
      headers: await _authHeaders(),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> findUserByEmail(String email) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/User/find-by-email/$email'),
      headers: await _authHeaders(),
    );
    return jsonDecode(res.body);
  }

  // Notifications
  static Future<Map<String, dynamic>> getNotifications() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/Notification'),
      headers: await _authHeaders(),
    );
    return jsonDecode(res.body);
  }

  static Future<void> markNotificationRead(String id) async {
    await http.patch(
      Uri.parse('$baseUrl/api/Notification/$id/read'),
      headers: await _authHeaders(),
    );
  }

  static Future<Map<String, dynamic>> getUnreadCount() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/Notification/unread-count'),
      headers: await _authHeaders(),
    );
    return jsonDecode(res.body);
  }

  // BillPayment
  static Future<Map<String, dynamic>> getBillers() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/BillPayment/billers'),
      headers: await _authHeaders(),
    );
    return jsonDecode(res.body);
  }

  // MoneyRequest
  static Future<Map<String, dynamic>> createMoneyRequest({
    required String toUserId,
    required double amount,
    String? note,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/MoneyRequest'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'toUserId': toUserId,
        'amount': amount,
        if (note != null) 'note': note,
      }),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getReceivedRequests() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/MoneyRequest/received'),
      headers: await _authHeaders(),
    );
    return jsonDecode(res.body);
  }
}