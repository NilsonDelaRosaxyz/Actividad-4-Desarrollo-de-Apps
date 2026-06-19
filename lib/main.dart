import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const EcoWattApp());
}

class EcoWattApp extends StatelessWidget {
  const EcoWattApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoWatt',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}
