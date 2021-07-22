import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';

class CircularProfilePicture extends StatelessWidget {
  final _stream;
  final _radius;
  const CircularProfilePicture({required final stream, final radius = kDefualtBorderRadius * 3}) : _stream = stream, _radius = radius;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _stream,
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
