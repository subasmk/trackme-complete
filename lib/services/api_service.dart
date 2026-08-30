// api_service.dart - TrackMe Backend API Integration
// Connect your Flutter app to the TrackMe social backend

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // UPDATE THIS to your deployed backend URL
  // For local development: 'http://10.0.2.2:8000' (Android emulator)
  // For production: your deployed backend URL
  static const String baseUrl = 'http://YOUR_SERVER_IP:8000';
  
  final storage = const FlutterSecureStorage();
  
  // ==================== AUTHENTICATION ====================
  
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: 'auth_token', value: data['token']);
      await storage.write(key: 'user_id', value: data['user_id'].toString());
      await storage.write(key: 'username', value: data['username']);
      return {'success': true, 'data': data};
    } else {
      final error = jsonDecode(response.body);
      return {'success': false, 'error': error['detail'] ?? 'Registration failed'};
    }
  }
  
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: 'auth_token', value: data['token']);
      await storage.write(key: 'user_id', value: data['user_id'].toString());
      await storage.write(key: 'username', value: data['username']);
      return {'success': true, 'data': data};
    } else {
      final error = jsonDecode(response.body);
      return {'success': false, 'error': error['detail'] ?? 'Login failed'};
    }
  }
  
  Future<void> logout() async {
    await storage.delete(key: 'auth_token');
    await storage.delete(key: 'user_id');
    await storage.delete(key: 'username');
  }
  
  Future<bool> isLoggedIn() async {
    final token = await storage.read(key: 'auth_token');
    return token != null;
  }
  
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final token = await storage.read(key: 'auth_token');
    if (token == null) return null;
    
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }
  
  // ==================== USER PROFILES ====================
  
  Future<Map<String, dynamic>> getPublicProfile(String username) async {
    final token = await storage.read(key: 'auth_token');
    
    final response = await http.get(
      Uri.parse('$baseUrl/users/$username'),
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      return {'success': true, 'data': jsonDecode(response.body)};
    } else {
      final error = jsonDecode(response.body);
      return {'success': false, 'error': error['detail'] ?? 'Profile not found'};
    }
  }
  
  Future<List<dynamic>> searchUsers(String query) async {
    final token = await storage.read(key: 'auth_token');
    
    final response = await http.get(
      Uri.parse('$baseUrl/users/search?q=$query'),
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }
  
  // ==================== GOALS ====================
  
  Future<List<dynamic>> getGoals() async {
    final token = await storage.read(key: 'auth_token');
    
    final response = await http.get(
      Uri.parse('$baseUrl/goals'),
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }
  
  Future<Map<String, dynamic>> createGoal({
    required String title,
    String? description,
    String? category,
    int? targetStreak,
  }) async {
    final token = await storage.read(key: 'auth_token');
    
    final response = await http.post(
      Uri.parse('$baseUrl/goals'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'description': description,
        'category': category,
        'target_streak': targetStreak ?? 0,
      }),
    );
    
    if (response.statusCode == 200) {
      return {'success': true, 'data': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': 'Failed to create goal'};
    }
  }
  
  // ==================== BADGES ====================
  
  Future<List<dynamic>> getAllBadges() async {
    final token = await storage.read(key: 'auth_token');
    
    final response = await http.get(
      Uri.parse('$baseUrl/badges'),
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }
  
  Future<List<dynamic>> getUserBadges(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/badges/user/$userId'),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }
  
  // ==================== SYNC HELPERS ====================
  
  // Sync local Hive goals to backend
  Future<void> syncGoalsToBackend(List<dynamic> localGoals) async {
    for (var goal in localGoals) {
      await createGoal(
        title: goal['title'] ?? goal.title,
        description: goal['description'] ?? goal.description,
        category: goal['category'] ?? goal.category,
        targetStreak: goal['targetStreak'] ?? goal.targetStreak,
      );
    }
  }
}
