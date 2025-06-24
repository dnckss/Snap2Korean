import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const Snap2KoreanApp());
}

class Snap2KoreanApp extends StatelessWidget {
  const Snap2KoreanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snap2Korean',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}