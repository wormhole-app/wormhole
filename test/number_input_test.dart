import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wormhole/widgets/number_input.dart';

void main() {
  group('number input', () {
    testWidgets('basic', (tester) async {
      int calledNTimes = 0;
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: NumberInput(
          initialValue: Future.value(0),
          maxValue: 10,
          minValue: -10,
          onValueChange: (v) {
            calledNTimes++;
          },
        ),
      ));
      expect(find.text('0'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      expect(calledNTimes, 1);
      await tester.pump(Duration.zero);

      expect(find.text('0'), findsNothing);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('maximum', (tester) async {
      int calledNTimes = 0;
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: NumberInput(
          initialValue: Future.value(9),
          maxValue: 10,
          minValue: -10,
          onValueChange: (v) {
            calledNTimes++;
          },
        ),
      ));
      await tester.pump(Duration.zero);
      expect(find.text('9'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      expect(calledNTimes, 1);
      await tester.pump(Duration.zero);

      expect(find.text('10'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(Duration.zero);

      // onvaluechange should not be called if we are on  edge
      expect(calledNTimes, 1);
      expect(find.text('10'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump(Duration.zero);

      // but decrement counts again from maximum
      expect(calledNTimes, 2);
      expect(find.text('9'), findsOneWidget);
    });

    testWidgets('minimum', (tester) async {
      int calledNTimes = 0;
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: NumberInput(
          initialValue: Future.value(-9),
          maxValue: 10,
          minValue: -10,
          onValueChange: (v) {
            calledNTimes++;
          },
        ),
      ));
      await tester.pump(Duration.zero);
      expect(find.text('-9'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.remove));
      expect(calledNTimes, 1);
      await tester.pump(Duration.zero);

      expect(find.text('-10'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump(Duration.zero);

      // onvaluechange should not be called if we are on  edge
      expect(calledNTimes, 1);
      expect(find.text('-10'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(Duration.zero);

      // but decrement counts again from maximum
      expect(calledNTimes, 2);
      expect(find.text('-9'), findsOneWidget);
    });

    testWidgets('value passed correctly', (tester) async {
      int passedvalue = 0;
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: NumberInput(
          initialValue: Future.value(7),
          maxValue: 10,
          minValue: -10,
          onValueChange: (v) {
            passedvalue = v;
          },
        ),
      ));
      await tester.pump(Duration.zero);
      expect(find.text('7'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(Duration.zero);

      expect(passedvalue, 8);
      expect(find.text('8'), findsOneWidget);
    });
  });
}
