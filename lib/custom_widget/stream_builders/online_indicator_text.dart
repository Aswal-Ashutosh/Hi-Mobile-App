import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hi/constants/firestore_costants.dart';
import 'package:hi/services/firebase_service.dart';

class OnlineIndicatorText extends StatelessWidget {
  final _email;
  const OnlineIndicatorText({required final email}): _email = email;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseService.getStreamToUserData(email: _email),
      builder: (context, snapshot){
      if(snapshot.hasData && snapshot.data != null){
        final bool online = snapshot.data?[UserDocumentField.ONLINE];
        return Text(online ? 'Online' : 'Offline', style: TextStyle(color: online ? Colors.white60 : Colors.white38, fontSize: 12, letterSpacing: 0.5));
      }else{
        return Text('Offline', style: TextStyle(color: Colors.grey));
      }
    });
  }
}