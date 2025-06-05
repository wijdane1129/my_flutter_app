import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class NutritionixService {
  Future<List<Map<String, dynamic>>> searchFoods(String query) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.nutritionixBaseUrl}/search/instant'),
        headers: {
          'x-app-id': ApiConfig.nutritionixAppId,
          'x-app-key': ApiConfig.nutritionixAppKey,
          'Content-Type': 'application/json',
        },
        body: json.encode({'query': query}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> common = data['common'] ?? [];
        return common.map((item) => {
          'name': item['food_name'],
          'calories': item['nf_calories'] ?? 0,
          'image': item['photo']['thumb'],
        }).toList();
      } else {
        throw Exception('Erreur lors de la recherche');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }
}