import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ventvo/main.dart';

void main() {
  testWidgets('Ventvo onboarding smoke test', (WidgetTester tester) async {
    // Start the app using the same ProviderScope configuration used by the
    // real application.
    await tester.pumpWidget(
      const ProviderScope(
        child: VentvoApp(),
      ),
    );

    // Let the welcome-screen entrance animation settle before asserting its
    // content.
    await tester.pumpAndSettle();

    // Verify the initial Ventvo welcome screen.
    expect(find.text('Ventvo'), findsOneWidget);
    expect(find.text('VENT your thoughts.'), findsOneWidget);
    expect(find.text('FIND your people.'), findsOneWidget);
    expect(find.text('FEEL understood.'), findsOneWidget);
    expect(find.text('Let it out. No judgement.'), findsOneWidget);
    expect(find.text('Start Venting'), findsOneWidget);

    // Continue through the onboarding flow.
    await tester.tap(find.text('Start Venting'));
    await tester.pumpAndSettle();

    // Verify the authentication choice screen.
    expect(
      find.text('Welcome to Ventvo'),
      findsOneWidget,
    );

    expect(
      find.text(
        "You don't have to carry everything alone.",
      ),
      findsOneWidget,
    );

    // The current authentication screen uses a separate email CTA rather
    // than the old "Create an Account" label.
    expect(
      find.text('Continue with Email'),
      findsOneWidget,
    );
  });
}
