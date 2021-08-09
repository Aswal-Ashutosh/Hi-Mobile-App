import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/constants/firestore_costants.dart';
import 'package:hi/custom_widget/stream_builders/circular_profile_picture.dart';
import 'package:hi/custom_widget/stream_builders/conditional_stream_builder.dart';
import 'package:hi/custom_widget/stream_builders/online_indicator_dot.dart';
import 'package:hi/custom_widget/stream_builders/text_stream_builder.dart';
import 'package:hi/screens/chat/one_to_one/chat_room.dart';
import 'package:hi/screens/profile_view/user_profile_view_screen.dart';
import 'package:hi/services/encryption_service.dart';
import 'package:hi/services/firebase_service.dart';

class ChatCardOneToOne extends StatelessWidget {
  final String _roomId;
  final String _friendEmail;
  final bool _lastMessageSeen;
  const ChatCardOneToOne(
      {required final String roomId,
      required final String friendEmail,
      required final bool lastMessageSeen})
      : _roomId = roomId,
        _friendEmail = friendEmail,
        _lastMessageSeen = lastMessageSeen;

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
                      ConditionalStreamBuilder(
                        stream: FirebaseService.getStreamToFriendDoc(email: _friendEmail),
                        childIfExist: OnlineIndicatorDot(email: _friendEmail),
                        childIfDoNotExist: Container(),
                      ),
                      if (_lastMessageSeen == false) Spacer(),
                      if (_lastMessageSeen == false)
                        Icon(Icons.message_rounded, color: Colors.green),
                    ],
                  ),
                  StreamBuilder<DocumentSnapshot>(
                    stream:
                        FirebaseService.getStreamToChatRoomDoc(roomId: _roomId),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        final docData = snapshot.data;
                        final lastMessageTime =
                            docData?[ChatDBDocumentField.LAST_MESSAGE_TIME];
                        final lastMessageDate =
                            docData?[ChatDBDocumentField.LAST_MESSAGE_DATE];
                        final lastMessageType =
                            docData?[ChatDBDocumentField.LAST_MESSAGE_TYPE];
                        String? lastMessage =
                            docData?[ChatDBDocumentField.LAST_MESSAGE];
                        if (lastMessage != null) {
                          lastMessage = EncryptionService.decrypt(lastMessage)
                              .replaceAll('\n', ' ');
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (lastMessageType == MessageType.IMAGE)
                                  Icon(
                                    Icons.photo,
                                    color: Colors.grey,
                                  ),
                                if (lastMessage != null)
                                  Flexible(
                                    child: Text(
                                      lastMessage,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: _lastMessageSeen
                                            ? Colors.grey
                                            : Colors.blueGrey,
                                        fontSize: 12,
                                        letterSpacing: 2.5,
                                        fontWeight: _lastMessageSeen
                                            ? FontWeight.normal
                                            : FontWeight.bold,
                                      ),
                                    ),
                                  )
                              ],
                            ),
                            SizedBox(height: 2.5),
                            Text(
                              '$lastMessageDate at $lastMessageTime',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: _lastMessageSeen
                                    ? Colors.grey
                                    : Colors.blueGrey,
                                fontSize: 10,
                                letterSpacing: 2.5,
                                fontWeight: _lastMessageSeen
                                    ? FontWeight.normal
                                    : FontWeight.bold,
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
