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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark
                  ? MessengerTheme.darkDividerColor
                  : MessengerTheme.dividerColor,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              activeIcon: Icon(Icons.chat_bubble_rounded),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline_rounded),
              activeIcon: Icon(Icons.people_rounded),
              label: 'People',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.circle_outlined),
              activeIcon: Icon(Icons.circle),
              label: 'Stories',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.call_outlined),
              activeIcon: Icon(Icons.call_rounded),
              label: 'Calls',
            ),
          ],
        ),
      ),
    );
  }
}
