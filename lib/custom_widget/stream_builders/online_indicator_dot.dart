import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hi/constants/firestore_costants.dart';
import 'package:hi/services/firebase_service.dart';

class OnlineIndicatorDot extends StatelessWidget {
  final _email;
  const OnlineIndicatorDot({required final email}): _email = email;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseService.getStreamToUserData(email: _email),
      builder: (context, snapshot){
      if(snapshot.hasData && snapshot.data != null){
        final bool online = snapshot.data?[UserDocumentField.ONLINE];
        return Icon(Icons.fiber_manual_record, color: online ? Colors.blue : Colors.grey, size: 12);
      }else{
        return Icon(Icons.fiber_manual_record, color: Colors.grey, size: 12);
      }
    });
  }
}