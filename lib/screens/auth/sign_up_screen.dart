import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/constants/error.dart';
import 'package:hi/custom_widget/buttons/primary_button.dart';
import 'package:hi/screens/auth/email_verification_screen.dart';
import 'package:hi/screens/auth/sign_in_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hi/services/firebase_service.dart';

class SignUpScreen extends StatelessWidget {
  static const id = 'sign_up_screen';
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
              Center(child: Text('Sign Up', style: TextStyle(fontSize: 40))),
              SizedBox(height: kDefaultPadding * 2),
              SignUpForm(),
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
    );
  }
}

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final formKey = GlobalKey<FormState>();

  final nameTextController = TextEditingController();
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  final nameValidator = (String? value) => value!.trim().isEmpty ? "Enter a name." : null;
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
    nameTextController.dispose();
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
            controller: nameTextController,
            validator: nameValidator,
            maxLength: 20,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: const Color(0x111F6FEB),
              labelText: 'Name',
              labelStyle: TextStyle(color: Colors.grey[650]),
              enabledBorder: borderRadius,
              focusedBorder: borderRadius,
              errorBorder: borderRadius,
              focusedErrorBorder: borderRadius,
              prefixIcon: Icon(Icons.person),
            ),
          ),
          SizedBox(height: kDefaultPadding),
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
              firebaseEmailError = null;
              if (formKey.currentState!.validate()) {
                await FirebaseAuth.instance
                .createUserWithEmailAndPassword(email: emailTextController.text.trim(), password: passwordTextController.text.trim())
                .then((value) async{ 
                  final String uid = (FirebaseAuth.instance.currentUser?.uid) as String;
                  await FirebaseService.createNewUser(uid: uid, email: emailTextController.text.trim(), name: nameTextController.text.trim());
                  Navigator.pushNamed(context, EmailVerificatoinScreen.id);
                 })
                .catchError((error) {
                  switch(error.code){
                    case 'email-already-in-use': setState(() {firebaseEmailError = email_already_in_use;}); break;
                    case 'invalid-email': setState(() {firebaseEmailError = invalid_email;}); break;
                    default: assert(false);
                  }
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
