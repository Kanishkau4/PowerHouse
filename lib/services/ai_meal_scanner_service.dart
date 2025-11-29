import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:powerhouse/models/food_item_model.dart';
import 'package:powerhouse/services/storage_service.dart';

class AIMealScannerService {
  // Get your API key from: https://makersuite.google.com/app/apikey
  static String get _geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  final _picker = ImagePicker();
  final _storageService = StorageService();
  late final GenerativeModel _model;

  AIMealScannerService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash', // ← Change this line
      apiKey: _geminiApiKey,
    );
  }

  // ========== SCAN MEAL FROM CAMERA ==========
  Future<List<FoodItemModel>?> scanMealFromCamera() async {
    try {
      // Pick image from camera
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo == null) return null;

      return await _analyzeMealImage(File(photo.path));
    } catch (e) {
      print('❌ Error scanning meal: $e');
      rethrow;
    }
  }

  // ========== SCAN MEAL FROM GALLERY ==========
  Future<List<FoodItemModel>?> scanMealFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) return null;

      return await _analyzeMealImage(File(image.path));
    } catch (e) {
      print('❌ Error scanning meal from gallery: $e');
      rethrow;
    }
  }

  // ========== ANALYZE MEAL IMAGE WITH GEMINI AI ==========
  Future<List<FoodItemModel>> _analyzeMealImage(File imageFile) async {
    try {
      print('🤖 Analyzing meal image with Gemini AI...');

      // Read image bytes
      final imageBytes = await imageFile.readAsBytes();

      // Create prompt for Gemini
      final prompt = '''
Analyze this food image and identify all food items visible. 
For each food item, provide:
1. Food name
2. Estimated calories (kcal)
3. Protein (grams)
4. Carbohydrates (grams)
5. Fat (grams)
6. Serving size description

If you see Sri Lankan food, identify it correctly (e.g., Rice & Curry, Kottu, Hoppers, etc.).

Return ONLY a JSON array in this exact format:
[
  {
    "name": "Food Name",
    "calories": 300,
    "protein": 15.5,
    "carbs": 45.0,
    "fat": 10.2,
    "serving": "1 plate (250g)"
  }
]

Be realistic with portion sizes and nutritional values.
''';

      // Send to Gemini
      final content = [
        Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)]),
      ];

      final response = await _model.generateContent(content);
      final responseText = response.text ?? '';

      print('✅ Gemini response received');
      print('Response: $responseText');

      // Upload image to Supabase Storage
      String? imageUrl;
      try {
        imageUrl = await _storageService.uploadFoodImage(imageFile);
        print('✅ Image uploaded to storage: $imageUrl');
      } catch (e) {
        print('⚠️ Failed to upload image, will use local path: $e');
      }

      // Parse JSON response
      final foods = _parseGeminiResponse(
        responseText,
        imageUrl ??
            imageFile.path, // Use storage URL if available, else local path
        imageUrl != null, // Flag to indicate if it's a URL or local path
      );

      print('✅ Identified ${foods.length} food items');
      return foods;
    } catch (e) {
      print('❌ Error analyzing meal: $e');
      rethrow;
    }
  }

  // ========== PARSE GEMINI RESPONSE ==========
  List<FoodItemModel> _parseGeminiResponse(
    String responseText,
    String imagePath,
    bool isUrl,
  ) {
    try {
      // Extract JSON from response (Gemini sometimes adds markdown)
      String jsonText = responseText.trim();

      // Remove markdown code blocks if present
      if (jsonText.startsWith('```json')) {
        jsonText = jsonText
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
      } else if (jsonText.startsWith('```')) {
        jsonText = jsonText.replaceAll('```', '').trim();
      }

      // Parse JSON
      final List<dynamic> jsonList = json.decode(jsonText);

      // Convert to FoodItemModel list
      return jsonList.map((item) {
        return FoodItemModel(
          foodId: 'scanned_${DateTime.now().millisecondsSinceEpoch}',
          foodName: item['name'] as String,
          servingSizeDescription: item['serving'] as String?,
          calories: (item['calories'] as num).toInt(),
          protein: (item['protein'] as num).toDouble(),
          carbs: (item['carbs'] as num).toDouble(),
          fat: (item['fat'] as num).toDouble(),
          isSriLankan: _isSriLankanFood(item['name'] as String),
          imageUrl: isUrl ? imagePath : null, // Set imageUrl if it's a URL
          localImagePath: isUrl
              ? null
              : imagePath, // Set localImagePath if it's local
          createdAt: DateTime.now(),
        );
      }).toList();
    } catch (e) {
      print('❌ Error parsing Gemini response: $e');
      throw Exception('Failed to parse AI response. Please try again.');
    }
  }

  // ========== CHECK IF SRI LANKAN FOOD ==========
  bool _isSriLankanFood(String foodName) {
    final sriLankanKeywords = [
      'rice',
      'curry',
      'kottu',
      'hopper',
      'string hopper',
      'pittu',
      'dhal',
      'parippu',
      'pol',
      'sambol',
      'roti',
      'kiribath',
      'watalappan',
      'coconut',
      'sri lankan',
    ];

    final lowerName = foodName.toLowerCase();
    return sriLankanKeywords.any((keyword) => lowerName.contains(keyword));
  }
}
