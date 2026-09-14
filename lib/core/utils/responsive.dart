import 'package:flutter/material.dart';
import 'package:messenger/theme/app_tokens.dart';

enum ScreenSize { compact, medium, expanded, large }

class Responsive {
  static ScreenSize sizeOf(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= AppBreakpoints.expanded) return ScreenSize.large;
    if (w >= AppBreakpoints.medium) return ScreenSize.expanded;
    if (w >= AppBreakpoints.compact) return ScreenSize.medium;
    return ScreenSize.compact;
  }

  static bool isCompact(BuildContext context) => sizeOf(context) == ScreenSize.compact;
  static bool isMedium(BuildContext context) => sizeOf(context) == ScreenSize.medium;
  static bool isExpanded(BuildContext context) =>
      sizeOf(context) == ScreenSize.expanded || sizeOf(context) == ScreenSize.large;
  static bool isLarge(BuildContext context) => sizeOf(context) == ScreenSize.large;

  static bool isMobile(BuildContext context) => MediaQuery.sizeOf(context).width < AppBreakpoints.compact;
  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= AppBreakpoints.compact &&
      MediaQuery.sizeOf(context).width < AppBreakpoints.medium;
  static bool isDesktop(BuildContext context) => MediaQuery.sizeOf(context).width >= AppBreakpoints.medium;
}

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= AppBreakpoints.medium && desktop != null) return desktop!;
    if (w >= AppBreakpoints.compact && tablet != null) return tablet!;
    return mobile;
  }
}

class MaxWidthContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool center;

  const MaxWidthContainer({
    super.key,
    required this.child,
    this.maxWidth = 560,
    this.padding,
    this.center = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: padding,
      child: child,
    );
    return center ? Center(child: c) : c;
  }
}

class AdaptivePadding extends StatelessWidget {
  final Widget child;
  const AdaptivePadding({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    double hPad = 16;
    if (w >= 840) hPad = 24;
    if (w >= 1200) hPad = 32;
    return Padding(padding: EdgeInsets.symmetric(horizontal: hPad), child: child);
  }
}

/// Helper for responsive values
T responsiveValue<T>(BuildContext context, {required T compact, T? medium, T? expanded, T? large}) {
  final s = Responsive.sizeOf(context);
  if (s == ScreenSize.large && large != null) return large;
  if ((s == ScreenSize.expanded || s == ScreenSize.large) && expanded != null) return expanded;
  if ((s == ScreenSize.medium || s == ScreenSize.expanded || s == ScreenSize.large) && medium != null) return medium;
  return compact;
}
