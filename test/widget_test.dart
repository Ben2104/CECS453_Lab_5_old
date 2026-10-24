import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab_assignment5/main.dart';
import 'package:lab_assignment5/mortgage.dart';
import 'package:lab_assignment5/mortgage_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> pumpApp(WidgetTester tester) async {
  final provider = await MortgageProvider.load();
  await tester.pumpWidget(
    ChangeNotifierProvider.value(value: provider, child: const MortgageApp()),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('default mortgage matches lab sample', () {
    final m = Mortgage();
    expect(m.getFormattedAmount(), '\$100,000.00');
    expect(m.formattedMonthlyPayment(), '\$449.04');
    // PDF screenshot shows $161,654.66: Float (32-bit) rounding artifact.
    // Double math gives the exact value 449.0452... * 360.
    expect(m.formattedTotalPayment(), '\$161,656.09');
    expect(m.getFormattedRate(), '3.5%');
  });

  test('first launch uses defaults; update persists for next launch', () async {
    final first = await MortgageProvider.load();
    expect(first.mortgage.getAmount(), 100000.0);
    expect(first.mortgage.getYears(), 30);
    expect(first.mortgage.getRate(), 0.035);

    await first.update(amount: 250000, years: 15, rate: 0.05);

    // Simulates relaunch: a fresh provider reads back from SharedPreferences.
    final relaunched = await MortgageProvider.load();
    expect(relaunched.mortgage.getAmount(), 250000.0);
    expect(relaunched.mortgage.getYears(), 15);
    expect(relaunched.mortgage.getRate(), 0.05);
  });

  testWidgets('input screen shows data saved in last launch', (tester) async {
    SharedPreferences.setMockInitialValues({
      MortgageProvider.keyAmount: 300000.0,
      MortgageProvider.keyYears: 10,
      MortgageProvider.keyRate: 0.0425,
    });
    await pumpApp(tester);
    expect(find.text('\$300,000.00'), findsOneWidget);
    expect(find.text('4.25%'), findsOneWidget);

    await tester.tap(find.text('MODIFY DATA'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, '300000.00'), findsOneWidget);
    expect(find.text('Interest Rate: 4.25%'), findsOneWidget);
    final radios = tester.widget<RadioGroup<int>>(find.byType(RadioGroup<int>));
    expect(radios.groupValue, 10);
  });

  testWidgets('modify flow updates summary via provider; terms dialog shows', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('\$449.04'), findsOneWidget);

    // Terms checkbox -> AlertDialog
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, true);

    // Modify screen
    await tester.tap(find.text('MODIFY DATA'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate((w) => w is Radio<int> && w.value == 15),
    );
    await tester.enterText(find.byType(TextField), '200000');
    await tester.scrollUntilVisible(
      find.text('5%'),
      100,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.ensureVisible(find.text('5%'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('5%'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('DONE'));
    await tester.pumpAndSettle();

    expect(find.text('\$200,000.00'), findsOneWidget);
    expect(find.text('15'), findsOneWidget);
    expect(find.text('5%'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getDouble(MortgageProvider.keyAmount), 200000.0);
    expect(prefs.getInt(MortgageProvider.keyYears), 15);
    expect(prefs.getDouble(MortgageProvider.keyRate), 0.05);
  });
}
