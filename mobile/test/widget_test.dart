import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:kabadiwala_mobile/main.dart';

void main() {
  testWidgets('App renders speaker button and big action buttons', (WidgetTester tester) async {
    await tester.pumpWidget(const KabadiwalaApp());

    // Verify speaker read-aloud button is present
    expect(find.byIcon(Icons.volume_up), findsOneWidget);

    // Verify Marathi title
    expect(find.text('कबाडीवाला कनेक्ट'), findsOneWidget);
  });
}
