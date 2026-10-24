import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mortgage.dart';

/// Shared state for both screens. Holds the current [Mortgage] and persists
/// the user's inputs (years, amount, rate) with SharedPreferences.
class MortgageProvider extends ChangeNotifier {
  static const String keyAmount = 'amount';
  static const String keyYears = 'years';
  static const String keyRate = 'rate';

  final SharedPreferences _prefs;
  Mortgage _mortgage;

  MortgageProvider._(this._prefs, this._mortgage);

  /// Restores the inputs saved in the last launch, or the defaults on first run.
  static Future<MortgageProvider> load() async {
    final prefs = await SharedPreferences.getInstance();
    final defaults = Mortgage();
    final mortgage = Mortgage.of(
      amount: prefs.getDouble(keyAmount) ?? defaults.getAmount(),
      years: prefs.getInt(keyYears) ?? defaults.getYears(),
      rate: prefs.getDouble(keyRate) ?? defaults.getRate(),
    );
    return MortgageProvider._(prefs, mortgage);
  }

  Mortgage get mortgage => _mortgage;

  /// Called by the input screen's DONE button.
  Future<void> update({
    required double amount,
    required int years,
    required double rate,
  }) async {
    _mortgage = Mortgage.of(amount: amount, years: years, rate: rate);
    notifyListeners();
    await Future.wait([
      _prefs.setDouble(keyAmount, _mortgage.getAmount()),
      _prefs.setInt(keyYears, _mortgage.getYears()),
      _prefs.setDouble(keyRate, _mortgage.getRate()),
    ]);
  }
}
