import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/custom_widget/buttons/primary_button.dart';

class SignInScreen extends StatelessWidget {
  //const SignInScreen({ Key? key }) : super(key: key);
  static const id = 'sign_in_screen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 40,
                ),
              ),
            ),
            SizedBox(height: kDefaultPadding * 2),
            SignInForm()
          ],
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
      borderSide: BorderSide(color: Colors.green));

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
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
                prefixIcon: Icon(Icons.person),
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
      ),
    );
  }
}
