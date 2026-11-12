import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ventvo/features/crash_out/screens/private_crash_outs_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'ventvo_crash_outs':
          '[{"id":"crash-1","ownerVoiceId":"voice-1","textContent":"I needed another perspective.","type":"text","createdAt":"2026-01-01T00:00:00.000","status":"spaceEntered","spaceId":"attention","matchedExperienceId":null}]',
      'ventvo_crash_out_space_experiences': '[]',
      'ventvo_crash_out_space_replies': '{}',
    });
  });

  testWidgets(
    'a Crash Out that entered a Space can reopen it without claiming a match',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: PrivateCrashOutsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('I needed another perspective.'), findsOneWidget);
      expect(find.text('Open Space'), findsOneWidget);
      expect(find.text('No other side has surfaced yet.'), findsNothing);

      await tester.tap(find.text('Open Space'));
      await tester.pumpAndSettle();

      expect(find.text('Crash Out Space'), findsOneWidget);
      expect(find.text('Prototype preview'), findsOneWidget);
      expect(find.text('Experiences'), findsOneWidget);
    },
  );
  testWidgets(
    'an older entered Crash Out can recover its Space destination',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'ventvo_crash_outs':
            '[{"id":"legacy-space","textContent":"I wish someone would notice when I am not okay.","type":"text","createdAt":"2026-01-01T00:00:00.000","status":"spaceEntered"}]',
        'ventvo_crash_out_space_experiences': '[]',
        'ventvo_crash_out_space_replies': '{}',
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: PrivateCrashOutsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Open Space'), findsOneWidget);
      await tester.tap(find.text('Open Space'));
      await tester.pumpAndSettle();

      expect(find.text('Crash Out Space'), findsOneWidget);
      expect(find.text('Being noticed'), findsOneWidget);
    },
  );

}
