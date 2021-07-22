import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hi/services/firebase_service.dart';

class UserNameText extends StatelessWidget {
  final String _email;
  final TextStyle? _style;
  const UserNameText({required final String email, final TextStyle? style})
      : _email = email,
        _style = style;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseService.getStreamToUserData(email: _email),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final userData = snapshot.data;
            final userName = userData?['display_name'];
            return Text(
              userName,
              style: _style,
            );
          } else {
            //TODO: Add Shimmer
            return Text('Loading...', style: TextStyle(color: Colors.grey));
          }
        });
  }
}
