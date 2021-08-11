import 'package:flutter/material.dart';
import 'package:hi/screens/auth/email_verification_screen.dart';
import 'package:hi/screens/auth/profile_setup_screen.dart';
import 'package:hi/screens/edit_profile/edit_profile_screen.dart';
import 'package:hi/screens/group/group_chat_selection_screen.dart';
import 'package:hi/screens/home/home_screen.dart';
import 'package:hi/screens/loading_screen.dart';
import 'package:hi/screens/auth/sign_in_screen.dart';
import 'package:hi/screens/auth/sign_up_screen.dart';
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
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        SignInScreen.id: (context) => SignInScreen(),
        SignUpScreen.id: (context) => SignUpScreen(),
        EmailVerificatoinScreen.id: (context) => EmailVerificatoinScreen(),
        HomeScreen.id: (context) => HomeScreen(),
        LoadingScreen.id: (context) => LoadingScreen(),
        EditProfileScreen.id: (context) => EditProfileScreen(),
        ProfileSetupScreen.id: (context) => ProfileSetupScreen(),
        GroupChatSelectionScreen.id: (context) => GroupChatSelectionScreen(),
      },
      initialRoute: LoadingScreen.id,
    );
  }
}
