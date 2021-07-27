import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/constants/firestore_costants.dart';
import 'package:hi/custom_widget/stream_builders/circular_profile_picture.dart';
import 'package:hi/custom_widget/stream_builders/online_indicator_dot.dart';
import 'package:hi/custom_widget/stream_builders/text_stream_builder.dart';
import 'package:hi/screens/chat/chat_room.dart';
import 'package:hi/services/encryption_service.dart';
import 'package:hi/services/firebase_service.dart';

class ChatCardOneToOne extends StatelessWidget {
  final String _roomId;
  final String _friendEmail;
  const ChatCardOneToOne(
      {required final String roomId, required final String friendEmail})
      : _roomId = roomId,
        _friendEmail = friendEmail;

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
                  StreamBuilder<DocumentSnapshot>(
                    stream:
                        FirebaseService.getStreamToChatRoomDoc(roomId: _roomId),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        final docData = snapshot.data;
                        final lastMessage = EncryptionService.decrypt(
                                docData?[ChatDBDocumentField.LAST_MESSAGE])
                            .replaceAll('\n', ' ');
                        final lastMessageTime =
                            docData?[ChatDBDocumentField.LAST_MESSAGE_TIME];
                        final lastMessageDate =
                            docData?[ChatDBDocumentField.LAST_MESSAGE_DATE];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lastMessage,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                letterSpacing: 2.5,
                              ),
                            ),
                            SizedBox(height: 2.5),
                            Text(
                              '$lastMessageDate at $lastMessageTime',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                                letterSpacing: 2.5,
                              ),
                            ),
                          ],
                        );
                      } else {
                        //TODO: Add Shimmer
                        return Text('Loading...',
                            style: TextStyle(color: Colors.grey));
                      }
                    },
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
              friendEamil: _friendEmail,
            ),
          ),
        );
      },
    );
  }
}
