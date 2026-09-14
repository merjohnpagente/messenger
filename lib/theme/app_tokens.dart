import 'package:flutter/material.dart';

/// Modern design tokens — radii, spacing, shadows, durations, gradients
class AppRadius {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 28;
  static const double pill = 999;

  static BorderRadius rXs = BorderRadius.circular(xs);
  static BorderRadius rSm = BorderRadius.circular(sm);
  static BorderRadius rMd = BorderRadius.circular(md);
  static BorderRadius rLg = BorderRadius.circular(lg);
  static BorderRadius rXl = BorderRadius.circular(xl);
  static BorderRadius rXxl = BorderRadius.circular(xxl);
}

class AppSpacing {
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s40 = 40;
}

class AppShadows {
  static const soft = BoxShadow(
    color: Color(0x14000000),
    blurRadius: 10,
    offset: Offset(0, 4),
  );
  static const medium = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 20,
    offset: Offset(0, 8),
  );
  static const strong = BoxShadow(
    color: Color(0x20000000),
    blurRadius: 30,
    offset: Offset(0, 12),
  );
  static const blue = BoxShadow(
    color: Color(0x330084FF),
    blurRadius: 24,
    offset: Offset(0, 8),
  );
}

class AppDurations {
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 400);
}

class AppGradients {
  static const primary = LinearGradient(
    colors: [Color(0xFF0084FF), Color(0xFF0066CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const primaryVivid = LinearGradient(
    colors: [Color(0xFF00C6FF), Color(0xFF0084FF), Color(0xFF7F00FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const darkBg = LinearGradient(
    colors: [Color(0xFF1A1A1E), Color(0xFF101012)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const lightBg = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const bubbleMine = LinearGradient(
    colors: [Color(0xFF0084FF), Color(0xFF0070DD)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const shimmerLight = LinearGradient(
    colors: [Color(0xFFF0F2F5), Color(0xFFE4E6EB), Color(0xFFF0F2F5)],
    begin: Alignment(-1, 0),
    end: Alignment(1, 0),
  );
  static const shimmerDark = LinearGradient(
    colors: [Color(0xFF2C2C2E), Color(0xFF3A3B3C), Color(0xFF2C2C2E)],
    begin: Alignment(-1, 0),
    end: Alignment(1, 0),
  );
}

class AppBreakpoints {
  static const double compact = 600;
  static const double medium = 840;
  static const double expanded = 1200;
  static const double large = 1440;
}
