import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';

class ProfilePictureStreamBuilder extends StatelessWidget {
  final _stream = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser?.email)
      .collection('profile_picture')
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _stream,
      builder: (context, snapshots) {
        if (snapshots.hasData && snapshots.data!.docs.isNotEmpty) {
          final imageUrl =
              (snapshots.data?.docs[0].data() as Map<String, dynamic>)['url'];
          return CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: NetworkImage(imageUrl),
            radius: kDefualtBorderRadius * 3,
          );
        } else {
          return CircleAvatar(
            child: Icon(
              Icons.person,
              color: Colors.grey,
              size: 50,
            ),
            backgroundColor: Colors.blueGrey,
            radius: kDefualtBorderRadius * 3,
          );
        }
      },
    );
  }
}
