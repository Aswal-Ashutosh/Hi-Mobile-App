import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/constants/firestore_costants.dart';
import 'package:hi/custom_widget/stream_builders/circular_profile_picture.dart';
import 'package:hi/custom_widget/stream_builders/text_stream_builder.dart';

class FriendCard extends StatelessWidget {
  final _friendEmail;
  const FriendCard({required final friendEmail}) : _friendEmail = friendEmail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kDefaultPadding / 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularProfilePicture(
            email: _friendEmail,
            radius: kDefualtBorderRadius * 1.5,
          ),
          SizedBox(width: kDefaultPadding / 2.0),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextStreamBuilder(
                  email: _friendEmail,
                  key: UserDocumentField.DISPLAY_NAME,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    letterSpacing: 2.5,
                  ),
                ),
                TextStreamBuilder(
                  email: _friendEmail,
                  key: UserDocumentField.ABOUT,
                  textOverflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    letterSpacing: 2.5,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
