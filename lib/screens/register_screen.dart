import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:messenger/core/providers/auth_provider.dart';
import 'package:messenger/core/services/supabase_service.dart';
import 'package:messenger/theme/messenger_theme.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _handleRegister() async {
    final name = _name.text.trim();
    final email = _email.text.trim();
    final pass = _password.text.trim();
    if (name.isEmpty || email.isEmpty || pass.length < 6) {
      setState(() => _error = 'Name, valid email and 6+ char password required');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      if (!SupabaseService.isReady) {
        // Offline dev fallback — still go home for UI demo
        if (mounted) context.go('/home');
        return;
      }
      await ref.read(authProvider.notifier).signUp(email, pass, name);
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF060606) : Colors.white,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: ()=> context.go('/login'))),
      body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 24), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SizedBox(height: 12),
        Center(child: Container(width: 80,height: 80,decoration: const BoxDecoration(shape: BoxShape.circle, color: MessengerTheme.messengerBlue), child: const Icon(Icons.person_add_rounded, color: Colors.white, size: 40))),
        const SizedBox(height: 16),
        Text('Create account', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text('Free forever — Supabase + WebRTC', textAlign: TextAlign.center, style: TextStyle(color: isDark? const Color(0xFFB0B3B8): MessengerTheme.textSecondary)),
        const SizedBox(height: 24),
        _field(_name, 'Full name', isDark),
        const SizedBox(height: 12),
        _field(_email, 'Email address', isDark, type: TextInputType.emailAddress),
        const SizedBox(height: 12),
        _field(_password, 'Password (6+ chars)', isDark, obscure: true),
        if (_error != null) Padding(padding: const EdgeInsets.only(top:12), child: Text(_error!, style: const TextStyle(color: MessengerTheme.messengerRed))),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: _loading?null:_handleRegister, style: ElevatedButton.styleFrom(backgroundColor: MessengerTheme.messengerBlue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical:16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: _loading? const SizedBox(width:20,height:20, child: CircularProgressIndicator(strokeWidth:2, color: Colors.white)): const Text('Create Account', style: TextStyle(fontWeight: FontWeight.bold))),
        TextButton(onPressed: ()=> context.go('/login'), child: const Text('Already have account? Log in', style: TextStyle(color: MessengerTheme.messengerBlue))),
      ]))),
    );
  }

  Widget _field(TextEditingController c, String hint, bool isDark, {bool obscure=false, TextInputType? type}) => TextField(
    controller: c, obscureText: obscure, keyboardType: type,
    decoration: InputDecoration(hintText: hint, filled: true, fillColor: isDark? const Color(0xFF1C1C1E): const Color(0xFFF5F5F5), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal:16, vertical:16)),
  );
}
