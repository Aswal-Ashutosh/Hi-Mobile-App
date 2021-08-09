import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hi/screens/home/home_screen.dart';
import 'package:hi/screens/welcome_screen.dart';
import 'package:hi/services/firebase_service.dart';

class LoadingScreen extends StatefulWidget {
  static const id = 'loading_screen';
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    loadStuff();
  }

  void loadStuff() async{
    await Firebase.initializeApp();
    if(FirebaseAuth.instance.currentUser != null && await FirebaseService.userHasSetupProfile)
      Navigator.popAndPushNamed(context, HomeScreen.id);
    else
      Navigator.popAndPushNamed(context, WelcomeScreen.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
