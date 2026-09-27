import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smyl_mobile/main.dart';

void main() {
  testWidgets('SMYL Global App Boot Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SmylGlobalApp(),
      ),
    );

    // Initial splash frame should render SMYL brand tagline
    expect(find.text('SMYL'), findsWidgets);
    expect(find.text('GLOBAL'), findsWidgets);
    expect(find.text('Move smarter with every journey.'), findsOneWidget);

    // Pump past splash duration
    await tester.pump(const Duration(milliseconds: 3500));
    await tester.pump();
  });
}
