import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/custom_widget/buttons/primary_button.dart';
import 'package:hi/screens/sign_in_screen.dart';
import 'package:hi/screens/sign_up_screen.dart';

class WelcomeScreen extends StatelessWidget {
  static const id = "welcome_screen";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Center(
                  child: Text(
                    'Hi',
                    style: TextStyle(
                      fontSize: 40,
                    ),
                  ),
                ),
                Container(
                padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PrimaryButton(displayText: 'Sign In', onPressed: () => Navigator.pushNamed(context, SignInScreen.id)),
                    SizedBox(height: kDefaultPadding * 0.5),
                    PrimaryButton(displayText: 'Sign Up', color: kSecondaryButtonColor, onPressed: () => Navigator.pushNamed(context, SignUpScreen.id)),
                  ],
                ),
              ),
            
          ],
        ),
      )
    );
  }
}