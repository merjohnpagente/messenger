import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:messenger/core/services/supabase_service.dart';
import 'package:messenger/theme/app_tokens.dart';
import 'package:messenger/theme/messenger_theme.dart';
import 'package:messenger/widgets/app_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    Timer(const Duration(milliseconds: 1850), () {
      if (!mounted) return;
      if (SupabaseService.isReady && SupabaseService.isLoggedIn) {
        context.go('/home');
      } else {
        context.go('/login');
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [Color(0xFF0A0A0F), Color(0xFF121214), Color(0xFF1A1A1E)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : const LinearGradient(
                  colors: [Color(0xFFFFFFFF), Color(0xFFF0F7FF), Color(0xFFE6F0FF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
        ),
        child: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: FadeTransition(
                  opacity: _fade,
                  child: ScaleTransition(
                    scale: _scale,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Hero(tag: 'app_logo', child: const AppLogo.large()),
                        const SizedBox(height: 24),
                        ShaderMask(
                          shaderCallback: (b) => AppGradients.primary.createShader(b),
                          child: Text(
                            'Messenger',
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.8,
                                ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Fast • Secure • Modern',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                letterSpacing: 0.6,
                                fontWeight: FontWeight.w500,
                                color: isDark ? const Color(0xFF8A8D91) : MessengerTheme.textSecondary,
                              ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.6,
                            color: MessengerTheme.messengerBlue,
                            backgroundColor: isDark ? Colors.white10 : const Color(0xFFE4E6EB),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 28,
                child: Column(
                  children: [
                    Text(
                      'from',
                      style: TextStyle(
                        color: isDark ? Colors.grey[600] : Colors.grey[500],
                        fontSize: 11,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            gradient: AppGradients.primary,
                          ),
                          child: const Icon(Icons.bolt_rounded, size: 14, color: Colors.white),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Messenger',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
