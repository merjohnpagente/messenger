import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:messenger/core/services/supabase_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      // $0 stack: Supabase session check (auto-refresh). Fallback to splash->login if not configured.
      if (SupabaseService.isReady && SupabaseService.isLoggedIn) {
        context.go('/home');
      } else {
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF060606) : Colors.white,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ang logo sa tunga
            Center(
              child: Image.asset(
                'assets/images/messenger_logo.png', // Siguroha naa ni sa imong assets folder
                width: 100,
                height: 100,
                errorBuilder: (context, error, stackTrace) {
                  // Kung wala pa imong image file, mogawas una ni nga icon para dili mag-error
                  return const Icon(Icons.chat,
                      size: 80, color: Color(0xFF0084FF));
                },
              ),
            ),
            // Ang "from Meta" sa ubos parehas sa tinuod nga app
            Positioned(
              bottom: 24,
              child: Column(
                children: [
                  Text(
                    'from',
                    style: TextStyle(
                      color: isDark ? Colors.grey[600] : Colors.grey[500],
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Meta',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
