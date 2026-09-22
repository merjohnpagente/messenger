class SupabaseConfig {
  static const url = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  // Support both legacy anon (eyJ...) and new publishable (sb_publishable_...) + new env name
  static const _anon = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  static const _publishable = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY', defaultValue: '');
  static String get anonKey => _anon.isNotEmpty ? _anon : _publishable;
  static const turnUrl = String.fromEnvironment('TURN_URL', defaultValue: 'turn:openrelay.metered.ca:80');
  static const turnUrl2 = String.fromEnvironment('TURN_URL2', defaultValue: 'turn:openrelay.metered.ca:443');
  static const turnUser = String.fromEnvironment('TURN_USER', defaultValue: 'openrelayproject');
  static const turnCred = String.fromEnvironment('TURN_CRED', defaultValue: 'openrelayproject');

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  static List<Map<String, dynamic>> get iceServers => [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
        {
          'urls': turnUrl,
          'username': turnUser,
          'credential': turnCred,
        },
        {
          'urls': turnUrl2,
          'username': turnUser,
          'credential': turnCred,
        },
      ];
}
