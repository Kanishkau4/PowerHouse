import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:powerhouse/models/food_item_model.dart';

class BarcodeScannerService {
  // Open Food Facts API (free, no API key needed)
  static const String _apiBaseUrl = 'https://world.openfoodfacts.org/api/v2';

  // ========== GET FOOD BY BARCODE ==========
  Future<FoodItemModel?> getFoodByBarcode(String barcode) async {
    try {
      print('📱 Fetching food data for barcode: $barcode');

      // Call Open Food Facts API
      final url = Uri.parse('$_apiBaseUrl/product/$barcode.json');
      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch barcode data');
      }

      final data = json.decode(response.body);

      if (data['status'] != 1) {
        print('⚠️ Product not found in database');
        return null;
      }

      final product = data['product'];

      // Extract nutritional info (per 100g)
      final nutriments = product['nutriments'] ?? {};

      // Get product name
      String productName = product['product_name'] ?? 'Unknown Product';

      // Prefer local language if available
      if (product['product_name_en'] != null) {
        productName = product['product_name_en'];
      }

      // Get serving size
      final servingSize = product['serving_size'] ?? '100g';

      // Get nutritional values (per 100g or serving)
      final calories = (nutriments['energy-kcal_100g'] ?? 0).toInt();
      final protein = (nutriments['proteins_100g'] ?? 0).toDouble();
      final carbs = (nutriments['carbohydrates_100g'] ?? 0).toDouble();
      final fat = (nutriments['fat_100g'] ?? 0).toDouble();

      // Get image
      final imageUrl = product['image_url'] as String?;

      print('✅ Product found: $productName');

      return FoodItemModel(
        foodId: 'barcode_$barcode',
        foodName: productName,
        servingSizeDescription: servingSize,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
        isSriLankan: false,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        localImagePath: null,
      );
    } catch (e) {
      print('❌ Error fetching barcode data: $e');
      rethrow;
    }
  }
}
