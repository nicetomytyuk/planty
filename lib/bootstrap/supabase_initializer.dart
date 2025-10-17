import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Initializes Supabase using credentials sourced from environment variables.
///
/// Expected variables:
/// - `SUPABASE_URL`
/// - `SUPABASE_ANON_KEY`
Future<void> initializeSupabase() async {
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseUrl.isEmpty) {
    throw StateError('Missing SUPABASE_URL in environment configuration.');
  }

  if (supabaseAnonKey == null || supabaseAnonKey.isEmpty) {
    throw StateError('Missing SUPABASE_ANON_KEY in environment configuration.');
  }

  try {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  } catch (error, stackTrace) {
    debugPrint('Supabase initialization failed: $error\n$stackTrace');
    rethrow;
  }
}
