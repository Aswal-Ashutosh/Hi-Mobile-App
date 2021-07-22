import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/custom_widget/profile_picture_stream_builder.dart';
import 'package:hi/services/firebase_service.dart';

class FriendCard extends StatelessWidget {
  final _friendEmail;

  const FriendCard({required final friendEmail}) : _friendEmail = friendEmail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kDefaultPadding / 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfilePictureStreamBuilder(
            stream:
                FirebaseService.getStreamToProfilePicture(email: _friendEmail),
            radius: kDefualtBorderRadius * 1.5,
          ),
          SizedBox(width: kDefaultPadding / 2.0),
          FutureBuilder(
            future: FirebaseService.getNameOf(email: _friendEmail),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(
                  snapshot.data as String,
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 15,
                    letterSpacing: 2.5,
                  ),
                );
              } else {
                //TODO: Add shimmer
                return Text(
                  'Loading...',
                  style: TextStyle(color: Colors.grey),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
