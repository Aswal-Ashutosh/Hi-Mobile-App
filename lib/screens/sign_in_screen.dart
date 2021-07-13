import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/custom_widget/buttons/primary_button.dart';
import 'package:hi/screens/sign_up_screen.dart';

class SignInScreen extends StatelessWidget {
  static const id = 'sign_in_screen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(child: Text('Sign In', style: TextStyle(fontSize: 40))),
              SizedBox(height: kDefaultPadding * 2),
              SignInForm(),
              SizedBox(height: kDefaultPadding),
              Row(
                children: [
                  Expanded(child: Divider(height: 1.5, color: Colors.black)),
                  Text('OR', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(child: Divider(height: 1.5, color: Colors.black)),
                ],
              ),
              SizedBox(height: kDefaultPadding),
              CircleAvatar(
                child: Image.asset('assets/google.png'),
                backgroundColor: Colors.grey,
              ),
              SizedBox(height: kDefaultPadding),
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
    );
  }
}

class SignInForm extends StatefulWidget {
  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  bool obscureText = true;
  final borderRadius = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(40)),
    borderSide: BorderSide(color: kPrimaryButtonColor),
  );

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0x332EA043),
              hintText: 'Your Email',
              enabledBorder: borderRadius,
              focusedBorder: borderRadius,
              errorBorder: borderRadius,
              focusedErrorBorder: borderRadius,
              prefixIcon: Icon(Icons.mail),
            ),
          ),
          SizedBox(height: kDefaultPadding),
          TextFormField(
            obscureText: obscureText,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0x332EA043),
              hintText: 'Password',
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
          PrimaryButton(displayText: 'Sign In', onPressed: () {}),
        ],
      ),
    );
  }
}
