import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_media_app/presentation/widgets/gradient_button.dart';

void main() {
  testWidgets('GradientButton shows its label and fires onPressed',
      (WidgetTester tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GradientButton(
              label: 'Publish Now',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Publish Now'), findsOneWidget);
    await tester.tap(find.text('Publish Now'));
    expect(tapped, isTrue);
  });

  testWidgets('disabled GradientButton does not fire', (WidgetTester tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GradientButton(label: 'Disabled', onPressed: null),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Disabled'));
    expect(tapped, isFalse);
  });
}
