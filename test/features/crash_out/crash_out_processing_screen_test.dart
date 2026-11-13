import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

import 'package:ventvo/features/crash_out/models/crash_out.dart';
import 'package:ventvo/features/crash_out/screens/crash_out_processing_screen.dart';

void main() {
  testWidgets(
    'processing failure keeps the Crash Out private and allows retry',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final crashOut = CrashOut(
        id: 'processing-failure-1',
        ownerVoiceId: 'voice-1',
        textContent: 'I wish someone would notice when I am not okay.',
        type: CrashOutType.text,
        createdAt: DateTime(2026, 1, 1),
      );
      final store = _ToggleFailingSharedPreferencesStore({
        'flutter.ventvo_voice_id': 'voice-1',
        'flutter.ventvo_voice_created_at': '2026-01-01T00:00:00.000',
        'flutter.ventvo_crash_outs': jsonEncode([
          {
            'id': crashOut.id,
            'ownerVoiceId': crashOut.ownerVoiceId,
            'textContent': crashOut.textContent,
            'type': crashOut.type.name,
            'createdAt': crashOut.createdAt.toIso8601String(),
            'status': crashOut.status.name,
          },
        ]),
        'flutter.ventvo_crash_out_space_experiences': '[]',
        'flutter.ventvo_crash_out_space_replies': '{}',
      });
      SharedPreferencesStorePlatform.instance = store;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: CrashOutProcessingScreen(crashOut: crashOut),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your Crash Out is still private.'), findsOneWidget);
      expect(
        find.text(
          'We couldn’t open the wider Space just now. Nothing from your original Crash Out was shared.',
        ),
        findsOneWidget,
      );
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('Return to Private'), findsOneWidget);

      store.throwOnWrite = false;
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(find.text('Crash Out Space'), findsOneWidget);
      expect(find.text('Prototype preview'), findsOneWidget);
    },
  );
}

class _ToggleFailingSharedPreferencesStore
    extends SharedPreferencesStorePlatform {
  _ToggleFailingSharedPreferencesStore(Map<String, Object> initialValues)
      : values = Map<String, Object>.of(initialValues);

  final Map<String, Object> values;
  bool throwOnWrite = true;

  @override
  Future<Map<String, Object>> getAll() async => Map<String, Object>.of(values);

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    if (throwOnWrite) {
      throw StateError('simulated local persistence failure');
    }
    values[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async => values.remove(key) != null;

  @override
  Future<bool> clear() async {
    values.clear();
    return true;
  }
}
