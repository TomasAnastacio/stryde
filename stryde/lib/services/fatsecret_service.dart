import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food_item.dart';

class FatSecretService {
  static const String _baseUrl = 'https://platform.fatsecret.com/rest';
  static const String _tokenUrl = 'https://oauth.fatsecret.com/connect/token';
  
  // These should be stored securely in environment variables or secure storage
  static const String _clientId = '23a3411220b847fa8348160164c512b6';
  static const String _clientSecret = '3f8400a095be4a1da7197789b12b1df9';
  
  String? _accessToken;
  DateTime? _tokenExpiry;

  // Singleton pattern
  static final FatSecretService _instance = FatSecretService._internal();
  factory FatSecretService() => _instance;
  FatSecretService._internal();

  /// Get OAuth 2.0 access token
  Future<void> _getAccessToken() async {
    if (_accessToken != null && 
        _tokenExpiry != null && 
        DateTime.now().isBefore(_tokenExpiry!)) {
      return; // Token is still valid
    }

    try {
      final credentials = base64Encode(utf8.encode('$_clientId:$_clientSecret'));
      
      final response = await http.post(
        Uri.parse(_tokenUrl),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'grant_type=client_credentials&scope=basic',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        final expiresIn = data['expires_in'] ?? 3600;
        _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));
      } else {
        throw Exception('Failed to get access token: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting access token: $e');
    }
  }

  /// Search for foods by name
  Future<List<FoodItem>> searchFoods(String query, {int maxResults = 20}) async {
    await _getAccessToken();
    
    try {
      final uri = Uri.parse('$_baseUrl/foods/search/v1').replace(
        queryParameters: {
          'search_expression': query,
          'max_results': maxResults.toString(),
          'format': 'json',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final foods = data['foods']?['food'] ?? [];
        
        if (foods is List) {
          return foods.map((food) => FoodItem.fromJson(Map<String, dynamic>.from(food))).toList();
        } else if (foods is Map) {
          return [FoodItem.fromJson(Map<String, dynamic>.from(foods))];
        }
        return [];
      } else {
        throw Exception('Failed to search foods: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching foods: $e');
    }
  }

  /// Get detailed food information by ID
  Future<FoodItem?> getFoodDetails(String foodId) async {
    await _getAccessToken();
    
    try {
      final uri = Uri.parse('$_baseUrl/food/v4').replace(
        queryParameters: {
          'food_id': foodId,
          'format': 'json',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return FoodItem.fromJson(Map<String, dynamic>.from(data['food']));
      } else {
        throw Exception('Failed to get food details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting food details: $e');
    }
  }

  /// Get food servings information
  Future<List<Map<String, dynamic>>> getFoodServings(String foodId) async {
    await _getAccessToken();
    
    try {
      final uri = Uri.parse('$_baseUrl/food/v4').replace(
        queryParameters: {
          'food_id': foodId,
          'format': 'json',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final servings = data['food']?['servings']?['serving'] ?? [];
        
        if (servings is List) {
          return List<Map<String, dynamic>>.from(servings);
        } else if (servings is Map) {
          return [Map<String, dynamic>.from(servings)];
        }
        return [];
      } else {
        throw Exception('Failed to get food servings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting food servings: $e');
    }
  }

  /// Get autocomplete suggestions for food search
  Future<List<String>> getAutocompleteSuggestions(String query) async {
    await _getAccessToken();
    
    try {
      final uri = Uri.parse('$_baseUrl/foods/autocomplete/v2').replace(
        queryParameters: {
          'expression': query,
          'format': 'json',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final suggestions = data['suggestions']?['suggestion'] ?? [];
        
        if (suggestions is List) {
          return suggestions.cast<String>();
        } else if (suggestions is String) {
          return [suggestions];
        }
        return [];
      } else {
        return []; // Return empty list if autocomplete fails
      }
    } catch (e) {
      return []; // Return empty list on error
    }
  }
}