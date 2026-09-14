import 'package:flutter/material.dart';

/// Modern messenger logo — bolt-in-bubble with gradient, no external asset required.
/// Original design inspired by Messenger but fully custom vector.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showShadow;
  final bool smallLabel;

  const AppLogo({
    super.key,
    this.size = 96,
    this.showShadow = true,
    this.smallLabel = false,
  });

  const AppLogo.small({super.key}) : size = 40, showShadow = false, smallLabel = false;
  const AppLogo.medium({super.key}) : size = 96, showShadow = true, smallLabel = false;
  const AppLogo.large({super.key}) : size = 120, showShadow = true, smallLabel = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.27),
        gradient: const LinearGradient(
          colors: [Color(0xFF00C6FF), Color(0xFF0084FF), Color(0xFF0066FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: showShadow
            ? [
                const BoxShadow(color: Color(0x400084FF), blurRadius: 24, offset: Offset(0, 8)),
                const BoxShadow(color: Color(0x1A000000), blurRadius: 16, offset: Offset(0, 4)),
              ]
            : null,
      ),
      child: CustomPaint(
        painter: _LogoPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

/// Minimal wordmark for app bar / splash
class AppWordmark extends StatelessWidget {
  final bool isDark;
  const AppWordmark({super.key, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppLogo.small(),
        const SizedBox(width: 10),
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            colors: [Color(0xFF0084FF), Color(0xFF0066FF)],
          ).createShader(b),
          child: const Text(
            'Messenger',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Bubble shape — rounded rect with tail
    final bubblePath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.15, h * 0.18, w * 0.70, h * 0.62),
        Radius.circular(w * 0.22),
      ));

    // Tail triangle at bottom
    final tail = Path()
      ..moveTo(w * 0.32, h * 0.72)
      ..lineTo(w * 0.26, h * 0.86)
      ..lineTo(w * 0.45, h * 0.74)
      ..close();

    // Draw subtle inner highlight
    final bubblePaint = Paint()..color = Colors.white;
    final shadowPaint = Paint()
      ..color = Colors.white.withOpacity(0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.012;

    // Bolt shape
    final bolt = Path()
      ..moveTo(w * 0.58, h * 0.28)
      ..lineTo(w * 0.42, h * 0.48)
      ..lineTo(w * 0.52, h * 0.50)
      ..lineTo(w * 0.44, h * 0.74)
      ..lineTo(w * 0.64, h * 0.47)
      ..lineTo(w * 0.52, h * 0.46)
      ..close();

    // Fill bubble
    canvas.drawPath(bubblePath, bubblePaint);
    canvas.drawPath(tail, bubblePaint);
    canvas.drawPath(bolt, Paint()..color = const Color(0xFF0084FF));

    // Bolt highlight
    final boltHighlight = Path()
      ..moveTo(w * 0.54, h * 0.32)
      ..lineTo(w * 0.44, h * 0.46)
      ..lineTo(w * 0.49, h * 0.47)
      ..lineTo(w * 0.56, h * 0.34)
      ..close();
    canvas.drawPath(boltHighlight, Paint()..color = Colors.white.withOpacity(0.35));

    // Inner stroke for bubble depth
    canvas.drawPath(bubblePath, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Simple circular fallback for very small contexts
class AppLogoCircle extends StatelessWidget {
  final double size;
  const AppLogoCircle({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF00C6FF), Color(0xFF0084FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [BoxShadow(color: Color(0x330084FF), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Icon(Icons.bolt_rounded, color: Colors.white, size: size * 0.55),
    );
  }
}
