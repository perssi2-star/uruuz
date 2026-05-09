import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wallet.dart';
import '../models/transaction.dart';

class ApiService {
  final String baseUrl;

  ApiService({this.baseUrl = 'http://localhost:8080'});

  Future<WalletBalance> getBalance(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/wallets/$userId/balance'));

    if (response.statusCode == 200) {
      return WalletBalance.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load balance: ${response.body}');
    }
  }

  Future<List<Transaction>> getHistory(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/wallets/$userId/history'));

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Transaction.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load history: ${response.body}');
    }
  }

  Future<void> transfer({
    required String senderUserId,
    required String receiverUserId,
    required int amount,
    String? description,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/wallets/$senderUserId/transfer'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'receiver_user_id': receiverUserId,
        'amount': amount,
        'description': description ?? '',
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Transfer failed: ${response.body}');
    }
  }

  Future<void> verifyNin(String userId, String nin) async {
    final response = await http.post(
      Uri.parse('$baseUrl/kyc/verify-nin'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': userId,
        'nin': nin,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('NIN verification failed: ${response.body}');
    }
  }

  Future<void> verifyFace(String userId, String imagePath) async {
    // For now, we'll just simulate a multi-part request or send the path
    final response = await http.post(
      Uri.parse('$baseUrl/kyc/verify-face'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': userId,
        'image_path': imagePath, // Placeholder for actual image data
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Face verification failed: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getKycStatus(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/kyc/status?user_id=$userId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch KYC status: ${response.body}');
    }
  }
}
