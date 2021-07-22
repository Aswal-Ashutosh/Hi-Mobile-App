import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/custom_widget/stream_builders/circular_profile_picture.dart';
import 'package:hi/custom_widget/stream_builders/user_name_text.dart';
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
          CircularProfilePicture(
            stream:
                FirebaseService.getStreamToProfilePicture(email: _friendEmail),
            radius: kDefualtBorderRadius * 1.5,
          ),
          SizedBox(width: kDefaultPadding / 2.0),
          UserNameText(
            email: _friendEmail,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 15,
              letterSpacing: 2.5,
            ),
          ),
        ],
      ),
    );
  }
}
