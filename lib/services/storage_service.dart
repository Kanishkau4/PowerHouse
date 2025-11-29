import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:powerhouse/core/config/supabase_config.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final SupabaseClient _supabase = SupabaseConfig.client;
  static const String _bucketName = 'food-images';

  // ========== UPLOAD FOOD IMAGE ==========
  /// Uploads a food image to Supabase Storage and returns the public URL
  Future<String> uploadFoodImage(File imageFile) async {
    try {
      print('📤 Uploading food image to Supabase Storage...');

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(imageFile.path);
      final fileName = 'food_$timestamp$extension';
      final filePath = 'scanned/$fileName';

      // Upload to Supabase Storage
      await _supabase.storage
          .from(_bucketName)
          .upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // Get public URL
      final publicUrl = _supabase.storage
          .from(_bucketName)
          .getPublicUrl(filePath);

      print('✅ Image uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('❌ Error uploading food image: $e');
      rethrow;
    }
  }

  // ========== DELETE FOOD IMAGE ==========
  /// Deletes a food image from Supabase Storage
  Future<void> deleteFoodImage(String imageUrl) async {
    try {
      // Extract file path from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      // Find the bucket name and file path
      final bucketIndex = pathSegments.indexOf(_bucketName);
      if (bucketIndex == -1) {
        throw Exception('Invalid image URL: bucket not found');
      }

      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

      print('🗑️ Deleting food image: $filePath');

      await _supabase.storage.from(_bucketName).remove([filePath]);

      print('✅ Image deleted successfully');
    } catch (e) {
      print('❌ Error deleting food image: $e');
      // Don't rethrow - deletion failures shouldn't break the app
    }
  }

  // ========== CHECK IF BUCKET EXISTS ==========
  /// Checks if the food-images bucket exists, creates it if not
  Future<void> ensureBucketExists() async {
    try {
      final buckets = await _supabase.storage.listBuckets();
      final bucketExists = buckets.any((bucket) => bucket.name == _bucketName);

      if (!bucketExists) {
        print('📦 Creating food-images bucket...');
        await _supabase.storage.createBucket(
          _bucketName,
          const BucketOptions(public: true),
        );
        print('✅ Bucket created successfully');
      }
    } catch (e) {
      print('⚠️ Error checking/creating bucket: $e');
      // Continue anyway - bucket might already exist
    }
  }
}
