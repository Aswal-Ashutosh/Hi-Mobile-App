import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';

class ProfilePictureStreamBuilder extends StatelessWidget {
  final _stream;
  final _radius;
  const ProfilePictureStreamBuilder({required final stream, final radius = kDefualtBorderRadius * 3}) : _stream = stream, _radius = radius;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _stream,
      builder: (context, snapshots) {
        if (snapshots.hasData && snapshots.data!.docs.isNotEmpty) {
          final imageUrl =
              snapshots.data?.docs[0]['url'];
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
