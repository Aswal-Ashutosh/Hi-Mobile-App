import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/constants/firestore_costants.dart';
import 'package:hi/custom_widget/stream_builders/circular_profile_picture.dart';
import 'package:hi/custom_widget/stream_builders/text_stream_builder.dart';
import 'package:hi/screens/chat/chat_room.dart';
import 'package:hi/services/firebase_service.dart';

class ChatCardOneToOne extends StatelessWidget {
  final String _roomId;
  const ChatCardOneToOne({required final String roomId}) : _roomId = roomId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: FirebaseService.getFriendsEmailOfChat(roomId: _roomId),
      builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        final String friendEmail = snapshot.data as String;
        return GestureDetector(
          child: Container(
            padding: const EdgeInsets.all(kDefaultPadding / 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProfilePicture(
                  email: friendEmail,
                  radius: kDefualtBorderRadius * 1.5,
                ),
                SizedBox(width: kDefaultPadding / 2.0),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextStreamBuilder(
                       stream: FirebaseService.getStreamToUserData(email: friendEmail),
                        key: UserDocumentField.DISPLAY_NAME,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          letterSpacing: 2.5,
                        ),
                      ),
                      TextStreamBuilder(
                        stream: FirebaseService.getStreamToUserData(email: friendEmail),
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatRoom(
                  roomId: _roomId,
                  friendEamil: friendEmail,
                ),
              ),
            );
          },
        );
      } else {
        //TODO: Add shimmer
        return LinearProgressIndicator();
      }
    });
  }
}
