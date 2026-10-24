import 'dart:math' as math;

/// Model: encapsulates the mortgage calculator.
class Mortgage {
  double _amount = 100000.0;
  int _years = 30;
  double _rate = 0.035; // fraction, 0.035 == 3.5%

  Mortgage();

  Mortgage.of({
    required double amount,
    required int years,
    required double rate,
  }) {
    setAmount(amount);
    setYears(years);
    setRate(rate);
  }

  void setAmount(double newAmount) {
    if (newAmount >= 0) _amount = newAmount;
  }

  void setYears(int newYears) {
    if (newYears >= 0) _years = newYears;
  }

  void setRate(double newRate) {
    if (newRate >= 0) _rate = newRate;
  }

  double getAmount() => _amount;
  int getYears() => _years;
  double getRate() => _rate;

  String getFormattedAmount() => money(_amount);

  /// Rate as a percent string without trailing zeros, e.g. "3.5%", "3.25%".
  String getFormattedRate() => '${formatPercent(_rate * 100)}%';

  double monthlyPayment() {
    final n = _years * 12;
    if (n == 0) return 0;
    final mRate = _rate / 12;
    if (mRate == 0) return _amount / n;
    final temp = math.pow(1 / (1 + mRate), n).toDouble();
    return _amount * mRate / (1 - temp);
  }

  String formattedMonthlyPayment() => money(monthlyPayment());

  double totalPayment() => monthlyPayment() * _years * 12;

  String formattedTotalPayment() => money(totalPayment());

  /// Equivalent of DecimalFormat("$#,##0.00").
  static String money(double value) {
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');
    final digits = parts[0].replaceFirst('-', '');
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
      buf.write(digits[i]);
    }
    final sign = value < 0 ? '-' : '';
    return '$sign\$$buf.${parts[1]}';
  }

  static String formatPercent(double percent) {
    var s = percent.toStringAsFixed(2);
    if (s.contains('.')) {
      s = s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
    }
    return s;
  }
}
