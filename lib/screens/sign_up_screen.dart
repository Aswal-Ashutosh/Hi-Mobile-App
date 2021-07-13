import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/custom_widget/buttons/primary_button.dart';
import 'package:hi/screens/email_verification_screen.dart';
import 'package:hi/screens/sign_in_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final formKey = GlobalKey<FormState>();
  final nameTextController = TextEditingController();
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  
  //TODO:Check if value can be null or not
  final nameValidator = (String? value) => value!.trim().isEmpty ? "Name can't be empty!" : null;

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  bool obscureText = true;
  final borderRadius = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(40)),
    borderSide: BorderSide(color: kSecondaryButtonColor),
  );

  @override
  void initState() {
    Firebase.initializeApp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: widget.nameTextController,
            validator: widget.nameValidator,
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
            controller: widget.emailTextController,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
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
            controller: widget.passwordTextController,
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
          PrimaryButton(displayText: 'Sign Up', color: kSecondaryButtonColor,onPressed: () async{
            //TODO:Remove print and Complete all validations
            print(widget.nameTextController.text);
            print(widget.emailTextController.text);
            print(widget.passwordTextController.text);
            widget.formKey.currentState!.validate();
            try{
              await FirebaseAuth.instance.createUserWithEmailAndPassword(email: widget.emailTextController.text, password: widget.passwordTextController.text);
              Navigator.pushNamed(context, EmailVerificatoinScreen.id);
            }catch(e){
              print(e.toString());
            }
          }),
        ],
      ),
    );
  }
}
