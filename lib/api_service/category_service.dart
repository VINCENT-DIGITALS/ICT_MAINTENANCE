import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_constants.dart';

class CategoryService {
  final String baseUrl = kBaseUrl;
  
  Future<List<Map<String, dynamic>>> fetchCategoriesWithSubcategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories-with-subcategories'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['status'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']['categories']);
        }
      }
      
      throw Exception('Failed to load categories: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }
}
