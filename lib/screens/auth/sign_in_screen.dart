import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/constants/error.dart';
import 'package:hi/custom_widget/buttons/primary_button.dart';
import 'package:hi/custom_widget/progressHud/progress_hud.dart';
import 'package:hi/screens/auth/email_verification_screen.dart';
import 'package:hi/screens/auth/profile_setup_screen.dart';
import 'package:hi/screens/home/home_screen.dart';
import 'package:hi/screens/auth/sign_up_screen.dart';
import 'package:hi/services/firebase_service.dart';

class SignInScreen extends StatefulWidget {
  static const id = 'sign_in_screen';

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool isLoading = false;

  void setLoading(bool condition) {
    setState(() {
      isLoading = condition;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      showIndicator: isLoading,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child: Text('Sign In', style: TextStyle(fontSize: 40))),
                SizedBox(height: kDefaultPadding * 2),
                SignInForm(loadingIndicatorCallback: setLoading),
                SizedBox(height: kDefaultPadding),
                Row(
                  children: [
                    Expanded(child: Divider(height: 1.5, color: Colors.black)),
                    Text('OR', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Divider(height: 1.5, color: Colors.black)),
                  ],
                ),
                SizedBox(height: kDefaultPadding),
                // CircleAvatar(
                //   child: Image.asset('assets/google.png'),
                //   backgroundColor: Colors.grey,
                // ),
                // SizedBox(height: kDefaultPadding),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Don\'t have an account?'),
                    SizedBox(width: kDefaultPadding / 5.0),
                    GestureDetector(
                      onTap: () =>
                          Navigator.popAndPushNamed(context, SignUpScreen.id),
                      child: Text(
                        'Sign Up',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SignInForm extends StatefulWidget {
  final Function loadingIndicatorCallback;
  const SignInForm({required this.loadingIndicatorCallback});
  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final formKey = GlobalKey<FormState>();

  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  final emailValidator =
      (String? value) => value!.trim().isEmpty ? "Enter an email." : null;
  final passwordValidator = (String? value) => value!.trim().length < 8
      ? 'Enter at least 8 character long password.'
      : null;

  bool obscureText = true;

  String? firebaseEmailError;
  String? firebasePasswordError;

  final borderRadius = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(kDefaultBorderRadius * 2)),
    borderSide: BorderSide(color: kPrimaryColor),
  );

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: emailTextController,
            validator: emailValidator,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              errorText: firebaseEmailError,
              filled: true,
              fillColor: const Color(0x112EA043),
              labelText: 'Email',
              enabledBorder: borderRadius,
              focusedBorder: borderRadius,
              errorBorder: borderRadius,
              focusedErrorBorder: borderRadius,
              prefixIcon: Icon(Icons.mail),
            ),
          ),
          SizedBox(height: kDefaultPadding),
          TextFormField(
            controller: passwordTextController,
            validator: passwordValidator,
            obscureText: obscureText,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              errorText: firebasePasswordError,
              filled: true,
              fillColor: const Color(0x112EA043),
              labelText: 'Password',
              enabledBorder: borderRadius,
              focusedBorder: borderRadius,
              errorBorder: borderRadius,
              focusedErrorBorder: borderRadius,
              prefixIcon: Icon(Icons.lock),
              suffixIcon: GestureDetector(
                  child: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility),
                  onTap: () {
                    setState(() {
                      obscureText = !obscureText;
                    });
                  }),
            ),
          ),
          SizedBox(height: kDefaultPadding),
          PrimaryButton(
              displayText: 'Sign In',
              onPressed: () async {
                widget.loadingIndicatorCallback(true);
                firebaseEmailError = null;
                firebasePasswordError = null;
                if (formKey.currentState!.validate()) {
                  await FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                          email: emailTextController.text.trim(),
                          password: passwordTextController.text.trim())
                      .then((value) async {
                    widget.loadingIndicatorCallback(true);
                    if (FirebaseAuth.instance.currentUser!.emailVerified) {
                      if (await FirebaseService.userHasSetupProfile)
                        Navigator.pushNamedAndRemoveUntil(
                            context, HomeScreen.id, (route) => false);
                      else
                        Navigator.popAndPushNamed(
                            context, ProfileSetupScreen.id);
                    } else {
                      Navigator.popAndPushNamed(
                          context, EmailVerificationScreen.id);
                    }
                  }).catchError((error) {
                    switch (error.code) {
                      case 'invalid-email':
                        setState(() {
                          firebaseEmailError = invalid_email;
                        });
                        break;
                      case 'user-not-found':
                        setState(() {
                          firebaseEmailError = user_not_found;
                        });
                        break;
                      case 'wrong-password':
                        setState(() {
                          firebasePasswordError = wrong_password;
                        });
                        break;
                      default:
                        assert(false);
                    }
                  });
                }
                widget.loadingIndicatorCallback(false);
              }),
        ],
      ),
    );
  }
}
