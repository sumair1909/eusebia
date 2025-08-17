import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eusebia_app/features/search/presentation/pages/search_page.dart';

void main() {
  group('SearchPage Widget Tests', () {
    testWidgets('should render search page structure', (
      WidgetTester tester,
    ) async {
      // Build the widget with error handling
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: SearchPage())),
      );

      // Wait for any async operations
      await tester.pumpAndSettle();

      // Verify the basic page structure renders
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should show search page title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: SearchPage())),
      );

      await tester.pumpAndSettle();

      // Verify the title is present
      expect(find.text('Search Tasks'), findsOneWidget);
    });
  });
}
