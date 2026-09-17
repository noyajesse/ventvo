import 'package:flutter_test/flutter_test.dart';
import 'package:ventvo/main.dart';

void main() {
  testWidgets('Ventvo opens with its welcome experience', (tester) async {
    await tester.pumpWidget(const VentvoApp());
    expect(find.text('Ventvo'), findsOneWidget);
    expect(find.text('Enter Ventvo'), findsOneWidget);
  });
}
