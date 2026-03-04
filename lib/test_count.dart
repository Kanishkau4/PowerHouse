import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:powerhouse/core/config/supabase_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SupabaseConfig.initialize();

  try {
    final response = await SupabaseConfig.client
        .from('teams')
        .select('*, team_members(count)')
        .limit(1);

    print('Teams with count: $response');
  } catch (e) {
    print('Error: $e');
  }
}
