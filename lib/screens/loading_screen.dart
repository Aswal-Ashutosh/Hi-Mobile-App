import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hi/screens/welcome_screen.dart';

class LoadingScreen extends StatefulWidget {
  static const id = 'loading_screen';
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    loadStuff();
    super.initState();
  }

  void loadStuff() async{
    await Firebase.initializeApp();
    Navigator.popAndPushNamed(context, WelcomeScreen.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Text('Loading'),
        ),
      ),
    );
  }
}
