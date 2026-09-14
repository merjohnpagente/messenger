import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:messenger/core/config/app_router.dart';
import 'package:messenger/core/services/supabase_service.dart';
import 'package:messenger/screens/calls_screen.dart';
import 'package:messenger/screens/chats_screen.dart';
import 'package:messenger/screens/people_screen.dart';
import 'package:messenger/screens/stories_screen.dart';
import 'package:messenger/theme/messenger_theme.dart';
import 'package:messenger/widgets/responsive_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('offline_queue');
  await Hive.openBox('cache');
  await SupabaseService.init();
  runApp(const ProviderScope(child: MessengerApp()));
}

class MessengerApp extends StatelessWidget {
  const MessengerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Messenger',
      debugShowCheckedModeBanner: false,
      theme: MessengerTheme.lightTheme,
      darkTheme: MessengerTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}

class MessengerHome extends StatefulWidget {
  const MessengerHome({super.key});

  @override
  State<MessengerHome> createState() => _MessengerHomeState();
}

class _MessengerHomeState extends State<MessengerHome> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    ChatsScreen(),
    PeopleScreen(),
    StoriesScreen(),
    CallsScreen(),
  ];

  static const _destinations = [
    AdaptiveDestination(
      icon: Icons.chat_bubble_outline_rounded,
      selectedIcon: Icons.chat_bubble_rounded,
      label: 'Chats',
    ),
    AdaptiveDestination(
      icon: Icons.people_outline_rounded,
      selectedIcon: Icons.people_rounded,
      label: 'People',
    ),
    AdaptiveDestination(
      icon: Icons.auto_awesome_outlined,
      selectedIcon: Icons.auto_awesome_rounded,
      label: 'Stories',
    ),
    AdaptiveDestination(
      icon: Icons.call_outlined,
      selectedIcon: Icons.call_rounded,
      label: 'Calls',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AdaptiveShell(
      selectedIndex: _selectedIndex,
      onSelected: (i) => setState(() => _selectedIndex = i),
      screens: _screens,
      destinations: _destinations,
    );
  }
}
