import 'package:flutter/material.dart';

class TipCategoryModel {
  final String categoryId;
  final String name;
  final String displayName;
  final String? iconName;
  final String? colorHex;
  final String? description;
  final int sortOrder;
  final DateTime createdAt;

  TipCategoryModel({
    required this.categoryId,
    required this.name,
    required this.displayName,
    this.iconName,
    this.colorHex,
    this.description,
    this.sortOrder = 0,
    required this.createdAt,
  });

  // From JSON (Supabase response)
  factory TipCategoryModel.fromJson(Map<String, dynamic> json) {
    return TipCategoryModel(
      categoryId: json['category_id'] as String,
      name: json['name'] as String,
      displayName: json['display_name'] as String,
      iconName: json['icon_name'] as String?,
      colorHex: json['color_hex'] as String?,
      description: json['description'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'name': name,
      'display_name': displayName,
      'icon_name': iconName,
      'color_hex': colorHex,
      'description': description,
      'sort_order': sortOrder,
    };
  }

  // Helper: Get color from hex string
  Color get color {
    if (colorHex == null) return const Color(0xFF1DAB87); // Default color

    try {
      final hexColor = colorHex!.replaceAll('#', '');
      return Color(int.parse('FF$hexColor', radix: 16));
    } catch (e) {
      return const Color(0xFF1DAB87); // Fallback color
    }
  }

  // Helper: Get icon data
  IconData get icon {
    switch (iconName) {
      case 'fitness_center':
        return Icons.fitness_center;
      case 'restaurant':
        return Icons.restaurant;
      case 'lightbulb':
        return Icons.lightbulb;
      case 'fact_check':
        return Icons.fact_check;
      case 'spa':
        return Icons.spa;
      case 'self_improvement':
        return Icons.self_improvement;
      default:
        return Icons.tips_and_updates;
    }
  }

  @override
  String toString() {
    return 'TipCategoryModel(name: $name, displayName: $displayName)';
  }
}
