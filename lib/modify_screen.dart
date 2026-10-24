import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'mortgage.dart';
import 'mortgage_provider.dart';

/// Right screen: edit years (radio), amount (text), interest rate (ListView).
class ModifyScreen extends StatefulWidget {
  const ModifyScreen({super.key});

  @override
  State<ModifyScreen> createState() => _ModifyScreenState();
}

class _ModifyScreenState extends State<ModifyScreen> {
  static const List<int> _yearOptions = [10, 15, 30];
  static const double _itemExtent = 48;

  /// 2.00 .. 15.00 percent in 0.25 steps (53 entries).
  static final List<double> _rates = List.generate(53, (i) => 2.0 + i * 0.25);

  late int _years;
  late int _rateIndex;
  late final TextEditingController _amountController;
  late final ScrollController _scrollController;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    // Start from the shared state (restored from SharedPreferences on launch).
    final m = context.read<MortgageProvider>().mortgage;
    _years = _yearOptions.contains(m.getYears()) ? m.getYears() : 30;
    _rateIndex = ((m.getRate() * 100 - 2.0) / 0.25).round().clamp(
      0,
      _rates.length - 1,
    );
    _amountController = TextEditingController(
      text: m.getAmount().toStringAsFixed(2),
    );
    _scrollController = ScrollController(
      initialScrollOffset: _rateIndex * _itemExtent,
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _done() {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount < 0) {
      setState(() => _amountError = 'Enter a valid amount');
      return;
    }
    context.read<MortgageProvider>().update(
      amount: amount,
      years: _years,
      rate: _rates[_rateIndex] / 100,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mortgage App'),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 110,
                  child: Text('Years', style: TextStyle(fontSize: 16)),
                ),
                Expanded(
                  child: RadioGroup<int>(
                    groupValue: _years,
                    onChanged: (v) => setState(() => _years = v ?? _years),
                    child: Row(
                      children: [
                        for (final y in _yearOptions) ...[
                          Radio<int>(value: y),
                          Text('$y'),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const SizedBox(
                  width: 110,
                  child: Text('Amount', style: TextStyle(fontSize: 16)),
                ),
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(errorText: _amountError),
                    onChanged: (_) {
                      if (_amountError != null) {
                        setState(() => _amountError = null);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Interest Rate: ${Mortgage.formatPercent(_rates[_rateIndex])}%',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: ListView.builder(
                  controller: _scrollController,
                  itemExtent: _itemExtent,
                  itemCount: _rates.length,
                  itemBuilder: (_, i) => ListTile(
                    key: ValueKey('rate-$i'),
                    selected: i == _rateIndex,
                    selectedTileColor: scheme.primaryContainer,
                    title: Text('${Mortgage.formatPercent(_rates[i])}%'),
                    onTap: () => setState(() => _rateIndex = i),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _done,
                child: const Text('DONE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
