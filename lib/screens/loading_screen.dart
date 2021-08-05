import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hi/custom_widget/progressHud/progress_hud.dart';
import 'package:hi/screens/home/home_screen.dart';
import 'package:hi/screens/welcome_screen.dart';
import 'package:hi/services/firebase_service.dart';

class LoadingScreen extends StatefulWidget {
  static const id = 'loading_screen';
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    loadStuff();
  }

  void loadStuff() async{
    await Firebase.initializeApp();
    if(FirebaseAuth.instance.currentUser != null && await FirebaseService.userHasSetupProfile){
      setState(() {
        isLoading = false;
      });
      Navigator.popAndPushNamed(context, HomeScreen.id);
    }
    else{
      setState(() {
        isLoading = false;
      });
      Navigator.popAndPushNamed(context, WelcomeScreen.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      showIndicator: isLoading,
      child: Scaffold(
        body: SafeArea(
          child: Container(
            child: Center(child: Text('Loading', style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold, color: Colors.grey))),
          ),
        ),
      ),
    );
  }
}
