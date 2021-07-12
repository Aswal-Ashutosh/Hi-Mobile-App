import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/custom%20widget/buttons/primary_button.dart';

class WelcomeScreen extends StatelessWidget {
  static const id = "welcome_screen";
  //const WelcomeScreen({ Key? key }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                child: Center(
                  child: Text(
                    'Hi',
                    style: TextStyle(
                      fontSize: 40,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PrimaryButton(displayText: 'Sign In', onPressed: (){}),
                    SizedBox(height: kDefaultPadding * 0.5),
                    PrimaryButton(displayText: 'Sign Up', color: kSecondaryButtonColor, onPressed: (){}),
                  ],
                ),
              ),
            )
          ],
        ),
      )
    );
  }
}