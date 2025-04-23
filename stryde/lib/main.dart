import 'package:flutter/material.dart';
import 'screens/auth/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stryde',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF4CD964),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CD964),
          primary: const Color(0xFF4CD964),
        ),
        fontFamily: 'Roboto',
      ),
      home: const HomePage(),
    );
  }
}