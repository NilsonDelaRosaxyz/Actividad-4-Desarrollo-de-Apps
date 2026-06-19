// Test básico de smoke para EcoWatt.
import 'package:flutter_test/flutter_test.dart';
import 'package:ecowatt/main.dart';

void main() {
  testWidgets('La app inicia y muestra el titulo EcoWatt', (WidgetTester tester) async {
    await tester.pumpWidget(const EcoWattApp());
    expect(find.text('EcoWatt'), findsOneWidget);
  });
}
