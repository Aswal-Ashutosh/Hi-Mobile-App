import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/custom_widget/buttons/primary_button.dart';

//TODO: Delete account if back key is pressed
class EmailVerificatoinScreen extends StatefulWidget {
  static const id = 'email_verification_screen';
  @override
  _EmailVerificatoinScreenState createState() =>
      _EmailVerificatoinScreenState();
}

class _EmailVerificatoinScreenState extends State<EmailVerificatoinScreen> with WidgetsBindingObserver{
  Timer? timer;

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    runEmailVerification();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    timer?.cancel();
    super.dispose();
    print('dispose');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async{
    if(state == AppLifecycleState.detached){
      print('detached');
      //Deleting currently created account if app is closed without verifying the email.
      await FirebaseAuth.instance.currentUser?.reload();
      if(!FirebaseAuth.instance.currentUser!.emailVerified){
        FirebaseAuth.instance.currentUser?.delete();
      }
    }else if(state == AppLifecycleState.inactive){
      print('inactive');
    }else if(state == AppLifecycleState.paused){
      print('paused');
    }else if(state == AppLifecycleState.resumed){
      print('resumed');
    }
    super.didChangeAppLifecycleState(state);
  }

  void runEmailVerification() {
    FirebaseAuth.instance.currentUser?.sendEmailVerification();
    timer = Timer.periodic(Duration(seconds: 3), (timer) async{
      if(await checkIfVerified()){
        //TODO: Naviage to home screen
      }
    });
  }

  Future<bool> checkIfVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();
    if(FirebaseAuth.instance.currentUser!.emailVerified){
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
              VerificatonMessage(),
              SizedBox(height: kDefaultPadding),
              PrimaryButton(
                displayText: 'Cancel Verification',
                color: Colors.red,
                onPressed: () async {
                  await FirebaseAuth.instance.currentUser?.delete();
                  Navigator.pop(context);
                }
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VerificatonMessage extends StatelessWidget {
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
            FirebaseAuth.instance.currentUser?.email??'Error',
            style: TextStyle(
              fontSize: 15.0,
              color: Colors.green,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(
            height: kDefaultPadding / 4.0,
            child: Divider(
              color: Colors.grey,
              thickness: 0.5,
            ),
          ),
          Text(
            'Kindly verify your account by clicking the link provided in the mail.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[650], height: 1.5, letterSpacing: 1.25),
          ),
        ],
      ),
      decoration: BoxDecoration(
        color: Color(0x332EA043),
        borderRadius:
            BorderRadius.all(Radius.circular(kDefualtBorderRadius / 2.0),),
      ),
    );
  }
}
