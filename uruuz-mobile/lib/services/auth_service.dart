import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final String baseUrl;
  final _storage = const FlutterSecureStorage();

  AuthService({this.baseUrl = 'http://localhost:8080'});

  Future<void> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String pin,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'pin': pin,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Signup failed: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> login(String phone, String pin) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'phone': phone,
        'pin': pin,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _storage.write(key: 'jwt_token', value: data['token']);
      await _storage.write(key: 'user_id', value: data['user_id']);
      return data;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: 'user_id');
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'user_id');
  }
}
