import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/constants/firestore_costants.dart';
import 'package:hi/custom_widget/stream_builders/circular_profile_picture.dart';
import 'package:hi/custom_widget/stream_builders/text_stream_builder.dart';
import 'package:hi/screens/chat/chat_room.dart';
import 'package:hi/services/firebase_service.dart';
import 'package:hi/services/uid_generator.dart';

class FriendCard extends StatelessWidget {
  final _friendEmail;
  const FriendCard({required final friendEmail}) : _friendEmail = friendEmail;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
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
                    stream: FirebaseService.getStreamToUserData(email: _friendEmail),
                    key: UserDocumentField.DISPLAY_NAME,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      letterSpacing: 2.5,
                    ),
                  ),
                  TextStreamBuilder(
                    stream: FirebaseService.getStreamToUserData(email: _friendEmail),
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
        final roomId = UidGenerator.getRoomIdFor(email1:_friendEmail , email2: FirebaseService.currentUserEmail);
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatRoom(roomId: roomId, friendEamil: _friendEmail)));
      },
    );
  }
}
