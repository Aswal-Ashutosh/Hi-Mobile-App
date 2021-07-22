import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/services/firebase_service.dart';

class CircularProfilePicture extends StatelessWidget {
  final _email;
  final _radius;
  const CircularProfilePicture({required final String email, final radius = kDefualtBorderRadius * 3}) : _email = email, _radius = radius;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseService.getStreamToUserData(email: _email),
      builder: (context, snapshots) {
        if (snapshots.hasData && snapshots.data != null && snapshots.data?['profile_image'] != null) {
          final imageUrl = snapshots.data?['profile_image'];
          return CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: NetworkImage(imageUrl),
            radius: _radius,
          );
        } else {
          return CircleAvatar(
            child: Icon(
              Icons.person,
              color: Colors.grey,
              size: _radius,
            ),
            backgroundColor: Colors.blueGrey,
            radius: _radius,
          );
        }
      },
    );
  }
}
