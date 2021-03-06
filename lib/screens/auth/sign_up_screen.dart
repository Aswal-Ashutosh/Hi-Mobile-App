import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/constants/error.dart';
import 'package:hi/custom_widget/buttons/primary_button.dart';
import 'package:hi/custom_widget/progressHud/progress_hud.dart';
import 'package:hi/screens/auth/email_verification_screen.dart';
import 'package:hi/screens/auth/sign_in_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpScreen extends StatefulWidget {
  static const id = 'sign_up_screen';

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool isLoading = false;

  void setLoading(bool condition){
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
                Center(child: Text('Sign Up', style: TextStyle(fontSize: 40))),
                SizedBox(height: kDefaultPadding * 2),
                SignUpForm(loadingIndicatorCallback: setLoading),
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
                    Text('Already have an account?'),
                    SizedBox(width: kDefaultPadding / 5.0),
                    GestureDetector(
                      onTap: () =>
                          Navigator.popAndPushNamed(context, SignInScreen.id),
                      child: Text(
                        'Sign In',
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

class SignUpForm extends StatefulWidget {
  final Function loadingIndicatorCallback;
  const SignUpForm({required this.loadingIndicatorCallback});
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final formKey = GlobalKey<FormState>();

  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  final emailValidator = (String? value) => value!.trim().isEmpty ? "Enter an email." : null;
  final passwordValidator = (String? value) => value!.trim().length < 8 ? 'Enter at least 8 character long password.' : null;

  bool obscureText = true;
  String? firebaseEmailError;

  final borderRadius = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(40)),
    borderSide: BorderSide(color: kSecondaryColor),
  );

  @override
  void dispose() {
    emailTextController.dispose();
    passwordTextController.dispose();
    super.dispose();
  }

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
              fillColor: const Color(0x111F6FEB),
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
              filled: true,
              fillColor: const Color(0x111F6FEB),
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
            displayText: 'Sign Up',
            color: kSecondaryColor,
            onPressed: () async {
              widget.loadingIndicatorCallback(true);
              firebaseEmailError = null;
              if (formKey.currentState!.validate()) {
                await FirebaseAuth.instance
                .createUserWithEmailAndPassword(email: emailTextController.text.trim(), password: passwordTextController.text.trim())
                .then((value) async{ 
                  widget.loadingIndicatorCallback(false);
                  Navigator.pushNamed(context, EmailVerificationScreen.id);
                 })
                .catchError((error) {
                  switch(error.code){
                    case 'email-already-in-use': setState(() {firebaseEmailError = email_already_in_use;}); break;
                    case 'invalid-email': setState(() {firebaseEmailError = invalid_email;}); break;
                    default: assert(false);
                  }
                });
              }
              widget.loadingIndicatorCallback(false);
            },
          ),
        ],
      ),
    );
  }
}
