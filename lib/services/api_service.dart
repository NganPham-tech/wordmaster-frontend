import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8080';
  
  static Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    throw Exception('API Error: ${response.statusCode}');
  }
  
  static Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    throw Exception('API Error: ${response.statusCode}');
  }
}