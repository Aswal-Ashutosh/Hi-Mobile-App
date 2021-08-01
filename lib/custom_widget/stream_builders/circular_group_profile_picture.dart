import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/constants/firestore_costants.dart';
import 'package:hi/services/firebase_service.dart';

class CircularGroupProfilePicture extends StatelessWidget {
  final _roomId;
  final _radius;
  const CircularGroupProfilePicture({required final String roomId, final radius = kDefualtBorderRadius * 3}) : _roomId = roomId, _radius = radius;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseService.getStreamToGroupData(roomId: _roomId),
      builder: (context, snapshots) {
        if (snapshots.hasData && snapshots.data != null && snapshots.data?[GroupDBDocumentField.GROUP_IMAGE] != null) {
          final imageUrl = snapshots.data?[GroupDBDocumentField.GROUP_IMAGE];
          return CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: NetworkImage(imageUrl),
            radius: _radius,
          );
        } else {
          return CircleAvatar(
            child: Icon(
              Icons.group,
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
