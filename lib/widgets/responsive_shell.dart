import 'package:flutter/material.dart';
import 'package:messenger/core/utils/responsive.dart';
import 'package:messenger/theme/app_tokens.dart';
import 'package:messenger/theme/messenger_theme.dart';

class AdaptiveShell extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<Widget> screens;
  final List<AdaptiveDestination> destinations;

  const AdaptiveShell({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.screens,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    final size = Responsive.sizeOf(context);
    final isCompact = size == ScreenSize.compact;
    final isMedium = size == ScreenSize.medium;

    if (isCompact) {
      return Scaffold(
        body: IndexedStack(index: selectedIndex, children: screens),
        bottomNavigationBar: _BottomNav(
          selectedIndex: selectedIndex,
          onSelected: onSelected,
          destinations: destinations,
        ),
      );
    }

    if (isMedium) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onSelected,
              labelType: NavigationRailLabelType.all,
              groupAlignment: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              indicatorColor: MessengerTheme.messengerBlue.withOpacity(0.12),
              selectedIconTheme: const IconThemeData(color: MessengerTheme.messengerBlue),
              unselectedIconTheme: IconThemeData(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF8A8D91)
                    : MessengerTheme.textSecondary,
              ),
              destinations: destinations
                  .map((d) => NavigationRailDestination(
                        icon: Icon(d.icon),
                        selectedIcon: Icon(d.selectedIcon),
                        label: Text(d.label),
                      ))
                  .toList(),
            ),
            VerticalDivider(width: 1, thickness: 1, color: Theme.of(context).dividerColor.withOpacity(0.1)),
            Expanded(child: IndexedStack(index: selectedIndex, children: screens)),
          ],
        ),
      );
    }

    // Expanded / Large : extended rail + max width container
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: true,
            minExtendedWidth: 240,
            selectedIndex: selectedIndex,
            onDestinationSelected: onSelected,
            leading: Padding(
              padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: AppGradients.primary,
                    ),
                    child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Text('Messenger',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                ],
              ),
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            indicatorColor: MessengerTheme.messengerBlue.withOpacity(0.1),
            selectedIconTheme: const IconThemeData(color: MessengerTheme.messengerBlue),
            destinations: destinations
                .map((d) => NavigationRailDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selectedIcon),
                      label: Text(d.label),
                    ))
                .toList(),
          ),
          VerticalDivider(width: 1, thickness: 1, color: Theme.of(context).dividerColor.withOpacity(0.1)),
          Expanded(child: IndexedStack(index: selectedIndex, children: screens)),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<AdaptiveDestination> destinations;
  const _BottomNav({required this.selectedIndex, required this.onSelected, required this.destinations});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: isDark ? MessengerTheme.darkDividerColor : MessengerTheme.dividerColor)),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: NavigationBar(
        height: 64,
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelected,
        backgroundColor: Colors.transparent,
        elevation: 0,
        indicatorColor: MessengerTheme.messengerBlue.withOpacity(0.14),
        destinations: destinations
            .map((d) => NavigationDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon, color: MessengerTheme.messengerBlue),
                  label: d.label,
                ))
            .toList(),
      ),
    );
  }
}

class AdaptiveDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Widget? badge;

  const AdaptiveDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.badge,
  });
}

class MaxWidthScaffold extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const MaxWidthScaffold({super.key, required this.child, this.maxWidth = 1200});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
