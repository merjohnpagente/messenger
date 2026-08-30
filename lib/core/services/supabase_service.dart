import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:messenger/core/config/supabase_config.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;
  static bool get isReady => SupabaseConfig.isConfigured;
  static User? get currentUser => isReady ? client.auth.currentUser : null;
  static bool get isLoggedIn => currentUser != null;

  static Future<void> init() async {
    if (!SupabaseConfig.isConfigured) return;
    await Supabase.initialize(url: SupabaseConfig.url, anonKey: SupabaseConfig.anonKey);
  }
}
