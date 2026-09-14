import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:messenger/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    Hive.init('./test_hive_temp');
    try { await Hive.openBox('offline_queue'); } catch (_) {}
    try { await Hive.openBox('cache'); } catch (_) {}
  });

  testWidgets('Messenger app renders home shell', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MessengerApp()));
    expect(find.byType(MaterialApp), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });

  testWidgets('Splash navigates to login when not configured', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MessengerApp()));
    await tester.pump(const Duration(milliseconds: 100));
    // Updated modern UI uses "Welcome back" / "Log in" headings
    expect(find.textContaining('Log in'), findsWidgets);
  });
}
