import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/constants/error.dart';
import 'package:hi/custom_widget/buttons/primary_button.dart';
import 'package:hi/screens/auth/profile_setup_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  static const id = 'email_verification_screen';
  @override
  _EmailVerificationScreenState createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? timer;

  bool resendButtonEnabled = false;

  @override
  void initState() {
    runEmailVerification();
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void runEmailVerification() async {
    await FirebaseAuth.instance.currentUser
        ?.sendEmailVerification()
        .catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Unable to send verification mail. Request again by clicking the Resend Button.')));
    });
    timer = Timer.periodic(Duration(seconds: 3), (timer) async {
      if (await checkIfVerified()) {
        Navigator.popAndPushNamed(context, ProfileSetupScreen.id);
      }
    });
  }

  Future<bool> checkIfVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();
    if (FirebaseAuth.instance.currentUser!.emailVerified) {
      timer?.cancel();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(kDefaultPadding / 2.0),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                  child: Text('Verification', style: TextStyle(fontSize: 40))),
              SizedBox(height: kDefaultPadding * 2),
              VerificationMessage(),
              SizedBox(height: kDefaultPadding * 2),
              if (resendButtonEnabled == false)
                TweenAnimationBuilder(
                  tween: Tween(begin: 60.0, end: 0.0),
                  duration: Duration(seconds: 60),
                  builder: (context, value, child) => Text(
                    'You can request again for verification mail in ${(value as double).toInt()} sec.',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  onEnd: () {
                    setState(() {
                      resendButtonEnabled = true;
                    });
                  },
                ),
              if (resendButtonEnabled == false)
                SizedBox(height: kDefaultPadding),
              PrimaryButton(
                displayText: 'Resend',
                color: resendButtonEnabled ? kPrimaryColor : Colors.grey,
                onPressed: resendButtonEnabled
                    ? () async {
                          await FirebaseAuth.instance.currentUser?.sendEmailVerification()
                          .then((value) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verification mail sent.'))))
                          .catchError((error) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(too_many_mail_request)));
                          });

                          setState(() {
                            resendButtonEnabled = false;
                          });
                      }
                    : () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VerificationMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kDefaultPadding / 2.0),
      child: Column(
        children: [
          Text(
            'Verification mail sent\nto',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[650],
              letterSpacing: 1.25,
            ),
          ),
          SizedBox(
            height: kDefaultPadding / 4.0,
          ),
          Text(
            FirebaseAuth.instance.currentUser?.email ?? 'Error',
            style: TextStyle(
              fontSize: 15.0,
              color: Colors.green,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(
            height: kDefaultPadding / 4.0,
          ),
          Text(
            'Kindly verify your email by clicking the link provided in the mail.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.grey[650], height: 1.5, letterSpacing: 1.25),
          ),
        ],
      ),
      decoration: BoxDecoration(
        color: Color(0x332EA043),
        borderRadius: BorderRadius.all(
          Radius.circular(kDefaultBorderRadius / 2.0),
        ),
      ),
    );
  }
}
