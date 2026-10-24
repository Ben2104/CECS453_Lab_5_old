import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'modify_screen.dart';
import 'mortgage_provider.dart';

/// Left screen: read-only summary + Terms and Conditions + Modify Data.
class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  bool _termsAccepted = false;

  // Data is shared through MortgageProvider, so nothing is passed or returned.
  void _modify() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const ModifyScreen()));
  }

  Future<void> _onTermsChanged(bool? checked) async {
    if (checked != true) {
      setState(() => _termsAccepted = false);
      return;
    }
    final accepted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Terms and Conditions'),
        content: const Text(
          'Do you confirm that you have read and agree to the terms and '
          'conditions of this mortgage?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Decline'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    setState(() => _termsAccepted = accepted ?? false);
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: const TextStyle(fontSize: 16)),
        ),
        Expanded(
          flex: 2,
          child: Text(value, style: const TextStyle(fontSize: 16)),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    // Rebuilds whenever the input screen updates the provider.
    final mortgage = context.watch<MortgageProvider>().mortgage;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mortgage App'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _row('Amount', mortgage.getFormattedAmount()),
          _row('Years', '${mortgage.getYears()}'),
          _row('Interest Rate', mortgage.getFormattedRate()),
          const Divider(color: Colors.red, thickness: 2),
          _row('Monthly Payment', mortgage.formattedMonthlyPayment()),
          _row('Total Payment', mortgage.formattedTotalPayment()),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('Terms and Conditions'),
            value: _termsAccepted,
            onChanged: _onTermsChanged,
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: _modify,
              child: const Text('MODIFY DATA'),
            ),
          ),
        ],
      ),
    );
  }
}
