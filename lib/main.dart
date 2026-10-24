import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'mortgage_provider.dart';
import 'summary_screen.dart';

Future<void> main() async {
  // SharedPreferences needs the platform channels before runApp.
  WidgetsFlutterBinding.ensureInitialized();
  final mortgageProvider = await MortgageProvider.load();
  runApp(
    ChangeNotifierProvider.value(
      value: mortgageProvider,
      child: const MortgageApp(),
    ),
  );
}

class MortgageApp extends StatelessWidget {
  const MortgageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mortgage App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const SummaryScreen(),
    );
  }
}
