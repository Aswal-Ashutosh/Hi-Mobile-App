import 'package:flutter/material.dart';
import 'package:hi/screens/welcome_screen.dart';

void main() {
  runApp(Hi());
}

class Hi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WelcomeScreen(),
    );
  }
}