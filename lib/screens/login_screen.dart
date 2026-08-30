import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:messenger/core/providers/auth_provider.dart';
import 'package:messenger/core/services/supabase_service.dart';
import 'package:messenger/theme/messenger_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Enter email and password');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      if (!SupabaseService.isReady) {
        // Dev fallback when .env not set — allow demo navigation
        if (mounted) context.go('/home');
        return;
      }
      await ref.read(authProvider.notifier).signIn(email, pass);
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', '').split(']').last.trim());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleForgot() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) { setState(()=> _error='Enter email to reset'); return; }
    try {
      if (!SupabaseService.isReady) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Configure Supabase to reset password'))); return; }
      await ref.read(authProvider.notifier).resetPassword(email);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reset link sent to $email')));
    } catch (e) { setState(()=> _error=e.toString()); }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF060606) : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              Center(
                child: Image.asset(
                  'assets/images/messenger_logo.png',
                  width: 96,
                  height: 96,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: MessengerTheme.messengerBlue,
                    ),
                    child: const Icon(
                      Icons.chat_bubble_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Log in to continue',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFFB0B3B8)
                          : MessengerTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Mobile number or email address',
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF1C1C1E)
                      : const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF1C1C1E)
                      : const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_error != null) Padding(padding: const EdgeInsets.only(bottom:12), child: Text(_error!, style: const TextStyle(color: MessengerTheme.messengerRed, fontSize: 13))),
              if (!SupabaseService.isReady) Container(margin: const EdgeInsets.only(bottom:12), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: isDark? const Color(0xFF3A3B3C): const Color(0xFFFFF3CD), borderRadius: BorderRadius.circular(8)), child: Row(children: [Icon(Icons.info_outline, size:16, color: isDark? Colors.amber: Colors.orange), const SizedBox(width:8), const Expanded(child: Text('Demo mode — add --dart-define SUPABASE_URL/ANON_KEY for real auth', style: TextStyle(fontSize:12)))])),
              ElevatedButton(
                onPressed: _loading?null:_handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MessengerTheme.messengerBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _loading? const SizedBox(width:20,height:20, child: CircularProgressIndicator(color: Colors.white, strokeWidth:2)): const Text(
                  'Log In',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/register'),
                child: const Text(
                  'Create new account',
                  style: TextStyle(
                    color: MessengerTheme.messengerBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              TextButton(
                onPressed: _handleForgot,
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFFB0B3B8)
                        : MessengerTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}