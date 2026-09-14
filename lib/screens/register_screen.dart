import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:messenger/core/providers/auth_provider.dart';
import 'package:messenger/core/services/supabase_service.dart';
import 'package:messenger/theme/app_tokens.dart';
import 'package:messenger/theme/messenger_theme.dart';
import 'package:messenger/widgets/app_logo.dart';

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
  bool _obscure = true;
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
    final w = MediaQuery.sizeOf(context).width;
    final isWide = w >= 900;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: isDark ? AppGradients.darkBg : AppGradients.lightBg),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 24, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isWide ? 980 : 460),
                child: isWide ? _wide(context, isDark) : _narrow(context, isDark),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _narrow(BuildContext context, bool isDark) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(alignment: Alignment.centerLeft, child: IconButton.filledTonal(onPressed: () => context.go('/login'), icon: const Icon(Icons.arrow_back_rounded))),
          const SizedBox(height: 12),
          Center(child: Hero(tag: 'app_logo_r', child: const AppLogo.medium())),
          const SizedBox(height: 16),
          Text('Create account', textAlign: TextAlign.center, style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.6)),
          const SizedBox(height: 6),
          Text('Join thousands — free forever', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          _card(context, isDark),
        ],
      );

  Widget _wide(BuildContext context, bool isDark) => Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(gradient: AppGradients.primary, borderRadius: BorderRadius.circular(28), boxShadow: const [AppShadows.blue]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const AppLogoCircle(size: 48),
                const SizedBox(height: 20),
                Text('Start your\njourney today.',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.white, height: 1.05, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                Text('Create an account in seconds and enjoy realtime messaging, media sharing and HD calls.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.9))),
                const SizedBox(height: 20),
                _check('End-to-end ready'),
                _check('No phone required'),
                _check('Works on web & mobile'),
              ]),
            ),
          ),
          const SizedBox(width: 32),
          Expanded(child: _card(context, isDark)),
        ],
      );

  Widget _check(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [Container(width: 22, height: 22, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.check_rounded, size: 14, color: Color(0xFF0084FF))), const SizedBox(width: 8), Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13))]),
      );

  Widget _card(BuildContext context, bool isDark) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E20) : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: isDark ? Colors.white10 : const Color(0x0F000000)),
          boxShadow: isDark ? [] : const [AppShadows.soft],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Sign up', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('It only takes a minute', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 20),
          _field(_name, 'Full name', Icons.person_outline_rounded, isDark),
          const SizedBox(height: 12),
          _field(_email, 'Email address', Icons.mail_outline_rounded, isDark, type: TextInputType.emailAddress),
          const SizedBox(height: 12),
          _field(_password, 'Password (6+ chars)', Icons.lock_outline_rounded, isDark, obscure: _obscure, suffix: IconButton(icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20), onPressed: ()=> setState(()=> _obscure=!_obscure))),
          if (_error != null)
            Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: MessengerTheme.messengerRed.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                child: Row(children: [const Icon(Icons.error_outline, color: MessengerTheme.messengerRed, size: 18), const SizedBox(width: 8), Expanded(child: Text(_error!, style: const TextStyle(color: MessengerTheme.messengerRed, fontSize: 13)))])),
          const SizedBox(height: 20),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _loading ? null : _handleRegister,
              style: ElevatedButton.styleFrom(backgroundColor: MessengerTheme.messengerBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: _loading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Create Account', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Already have an account?', style: Theme.of(context).textTheme.bodySmall),
            TextButton(onPressed: () => context.go('/login'), child: const Text('Log in', style: TextStyle(color: MessengerTheme.messengerBlue, fontWeight: FontWeight.w700))),
          ]),
          const SizedBox(height: 4),
          IconButton.filledTonal(onPressed: () => context.go('/login'), icon: const Icon(Icons.arrow_back_rounded, size: 18)),
        ]),
      );

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
}
