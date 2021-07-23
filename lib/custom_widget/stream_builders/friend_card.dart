import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hi/constants/constants.dart';
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
            email:_friendEmail,
            radius: kDefualtBorderRadius * 1.5,
          ),
          SizedBox(width: kDefaultPadding / 2.0),
          TextStreamBuilder(
            email: _friendEmail,
            key: 'display_name',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 15,
              letterSpacing: 2.5,
            ),
          ),
        ],
      ),
    );
  }
}
