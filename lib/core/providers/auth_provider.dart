import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:messenger/core/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) => AuthNotifier());

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  AuthNotifier() : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    if (!SupabaseService.isReady) {
      state = const AsyncValue.data(null);
      return;
    }
    final user = SupabaseService.currentUser;
    state = AsyncValue.data(user);
    SupabaseService.client.auth.onAuthStateChange.listen((data) {
      state = AsyncValue.data(data.session?.user);
    });
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final res = await SupabaseService.client.auth.signInWithPassword(email: email, password: password);
      state = AsyncValue.data(res.user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    state = const AsyncValue.loading();
    try {
      final res = await SupabaseService.client.auth.signUp(email: email, password: password, data: {'name': name});
      state = AsyncValue.data(res.user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await SupabaseService.client.auth.signOut();
    state = const AsyncValue.data(null);
  }

  Future<void> resetPassword(String email) async {
    await SupabaseService.client.auth.resetPasswordForEmail(email);
  }
}
