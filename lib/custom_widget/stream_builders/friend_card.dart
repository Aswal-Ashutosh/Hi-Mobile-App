import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/constants/firestore_costants.dart';
import 'package:hi/custom_widget/stream_builders/circular_profile_picture.dart';
import 'package:hi/custom_widget/stream_builders/text_stream_builder.dart';
import 'package:hi/screens/chat/one_to_one/chat_room.dart';
import 'package:hi/screens/profile_view/user_profile_view_screen.dart';
import 'package:hi/services/firebase_service.dart';
import 'package:hi/services/uid_generator.dart';

import 'online_indicator_dot.dart';

class FriendCard extends StatelessWidget {
  final _friendEmail;
  const FriendCard({required final friendEmail}) : _friendEmail = friendEmail;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        padding: const EdgeInsets.all(kDefaultPadding / 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      UserProfileScreen(userEmail: _friendEmail),
                ),
              ),
              child: CircularProfilePicture(
                email: _friendEmail,
                radius: kDefualtBorderRadius * 1.5,
              ),
            ),
            SizedBox(width: kDefaultPadding / 2.0),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TextStreamBuilder(
                        stream: FirebaseService.getStreamToUserData(
                            email: _friendEmail),
                        key: UserDocumentField.DISPLAY_NAME,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          letterSpacing: 2.5,
                        ),
                      ),
                      SizedBox(width: kDefaultPadding / 4.0),
                      OnlineIndicatorDot(email: _friendEmail)
                    ],
                  ),
                  TextStreamBuilder(
                    stream: FirebaseService.getStreamToUserData(
                        email: _friendEmail),
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
      ),
      onTap: () {
        final roomId = UidGenerator.getRoomIdFor(
            email1: _friendEmail, email2: FirebaseService.currentUserEmail);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ChatRoom(roomId: roomId, friendEamil: _friendEmail)));
      },
    );
  }
}
