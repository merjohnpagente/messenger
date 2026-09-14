import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:messenger/core/providers/auth_provider.dart';
import 'package:messenger/core/services/supabase_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:messenger/core/utils/responsive.dart';
import 'package:messenger/theme/app_tokens.dart';
import 'package:messenger/theme/messenger_theme.dart';
import 'package:messenger/widgets/app_logo.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
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
    final w = MediaQuery.sizeOf(context).width;
    final isWide = w >= 900;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppGradients.darkBg : AppGradients.lightBg,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 24, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isWide ? 980 : 440),
                child: isWide ? _buildWide(context, isDark) : _buildNarrow(context, isDark),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNarrow(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Center(child: Hero(tag: 'app_logo', child: const AppLogo.medium())),
        const SizedBox(height: 16),
        ShaderMask(
          shaderCallback: (b) => AppGradients.primary.createShader(b),
          child: Text('Welcome back',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: -0.6)),
        ),
        const SizedBox(height: 6),
        Text('Log in to continue to Messenger',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isDark ? const Color(0xFFB0B3B8) : MessengerTheme.textSecondary)),
        const SizedBox(height: 28),
        _formCard(context, isDark),
        const SizedBox(height: 20),
        _footerLinks(context, isDark),
      ],
    );
  }

  Widget _buildWide(BuildContext context, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: AppGradients.primaryVivid,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [AppShadows.blue, AppShadows.medium],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.bolt_rounded, color: Color(0xFF0084FF), size: 32),
                ),
                const SizedBox(height: 24),
                Text('Connect instantly\nwith anyone.',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.white, height: 1.1, fontWeight: FontWeight.w900, fontSize: 32)),
                const SizedBox(height: 12),
                Text('Modern messaging — fast, secure, and beautifully crafted for every device.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.9), height: 1.5)),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _pill('⚡ Realtime chat'),
                    _pill('🔒 Secure'),
                    _pill('🎥 HD Calls'),
                  ],
                ),
                const SizedBox(height: 32),
                Row(children: [
                  for (int i = 0; i < 3; i++)
                    Align(
                      widthFactor: 0.7,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(radius: 16, backgroundImage: NetworkImage('https://api.dicebear.com/7.x/avataaars/svg?seed=${['sarah','mike','emma'][i]}')),
                      ),
                    ),
                  const SizedBox(width: 12),
                  const Text('Trusted by thousands', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                ]),
              ],
            ),
          ),
        ),
        const SizedBox(width: 32),
        Expanded(child: Column(children: [_formCard(context, isDark), const SizedBox(height: 16), _footerLinks(context, isDark)])),
      ],
    );
  }

  Widget _pill(String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(999), border: Border.all(color: Colors.white24)),
        child: Text(t, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
      );

  Widget _formCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E20) : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0x0F000000)),
        boxShadow: isDark ? [] : const [AppShadows.soft],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!Responsive.isDesktop(context))
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 32, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white12 : const Color(0xFFE4E6EB), borderRadius: BorderRadius.circular(999))),
              ],
            ),
          if (!Responsive.isDesktop(context)) const SizedBox(height: 16),
          Text('Log in',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.3)),
          const SizedBox(height: 4),
          Text('Enter your credentials to continue', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 20),
          _field(_emailController, 'Email address', Icons.mail_outline_rounded, isDark, type: TextInputType.emailAddress),
          const SizedBox(height: 12),
          _field(_passwordController, 'Password', Icons.lock_outline_rounded, isDark, obscure: _obscure, suffix: IconButton(
            icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: MessengerTheme.textSecondary),
            onPressed: () => setState(()=> _obscure = !_obscure),
          )),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: _handleForgot, child: const Text('Forgot password?', style: TextStyle(color: MessengerTheme.messengerBlue, fontWeight: FontWeight.w600))),
          ),
          if (_error != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12, top: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: MessengerTheme.messengerRed.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: MessengerTheme.messengerRed.withOpacity(0.2))),
              child: Row(children: [const Icon(Icons.error_outline, size: 18, color: MessengerTheme.messengerRed), const SizedBox(width: 8), Expanded(child: Text(_error!, style: const TextStyle(color: MessengerTheme.messengerRed, fontSize: 13)))]),
            ),
          if (!SupabaseService.isReady)
            Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2416) : const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFCC02).withOpacity(0.35))),
                child: Row(children: [
                  const Icon(Icons.info_outline, size: 18, color: Color(0xFF8A6D00)),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('Demo mode — add SUPABASE_URL for live auth', style: TextStyle(fontSize: 12, color: Color(0xFF5D4A00)))),
                ])),
          const SizedBox(height: 8),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _loading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: MessengerTheme.messengerBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _loading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4))
                  : const Text('Log In', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: Divider(color: isDark ? Colors.white10 : const Color(0xFFE4E6EB))),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('or', style: Theme.of(context).textTheme.bodySmall)),
            Expanded(child: Divider(color: isDark ? Colors.white10 : const Color(0xFFE4E6EB))),
          ]),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => context.go('/register'),
            icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
            label: const Text('Create new account', style: TextStyle(fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              foregroundColor: MessengerTheme.messengerBlue,
              side: const BorderSide(color: MessengerTheme.messengerBlue, width: 1.2),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String hint, IconData icon, bool isDark, {bool obscure = false, TextInputType? type, Widget? suffix}) => TextField(
        controller: c,
        obscureText: obscure,
        keyboardType: type,
        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, size: 20, color: MessengerTheme.textSecondary),
          suffixIcon: suffix,
          filled: true,
          fillColor: isDark ? const Color(0xFF232324) : const Color(0xFFF5F5F7),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: isDark ? Colors.white10 : const Color(0xFFE8EAED))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: MessengerTheme.messengerBlue, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      );

  Widget _footerLinks(BuildContext context, bool isDark) => Column(children: [
        Text('By continuing you agree to our Terms & Privacy Policy',
            textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 11)),
        const SizedBox(height: 8),
        Text('© 2025 Messenger • Crafted with ♥', textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 11)),
      ]);
}
