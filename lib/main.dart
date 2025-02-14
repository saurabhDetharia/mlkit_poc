import 'package:flutter/material.dart';
import 'package:ml_kit_poc/main_poc.dart';

bool get isPoc => false;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
        ),
        useMaterial3: true,
      ),
      home: const MainPoc(
        title: 'Google ML-Kit POC',
      ),
    );
  }
}
