import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/constants/firestore_costants.dart';
import 'package:hi/custom_widget/stream_builders/circular_group_profile_picture.dart';
import 'package:hi/custom_widget/stream_builders/text_stream_builder.dart';
import 'package:hi/screens/chat/group_chat/group_chat_room.dart';
import 'package:hi/services/encryption_service.dart';
import 'package:hi/services/firebase_service.dart';

class GroupChatCard extends StatelessWidget {
  final String _roomId;
  const GroupChatCard({required final String roomId}) : _roomId = roomId;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        padding: const EdgeInsets.all(kDefaultPadding / 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularGroupProfilePicture(
              roomId: _roomId,
              radius: kDefualtBorderRadius * 1.5,
            ),
            SizedBox(width: kDefaultPadding / 2.0),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextStreamBuilder(
                    stream:
                        FirebaseService.getStreamToGroupData(roomId: _roomId),
                    key: ChatDBDocumentField.GROUP_NAME,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      letterSpacing: 2.5,
                    ),
                  ),
                  StreamBuilder<DocumentSnapshot>(
                    stream:
                        FirebaseService.getStreamToGroupData(roomId: _roomId),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        final docData = snapshot.data;
                        final lastMessageType =
                            docData?[ChatDBDocumentField.LAST_MESSAGE_TYPE];
                        if (lastMessageType != null) {
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
                                          color: Colors.grey,
                                          fontSize: 12,
                                          letterSpacing: 2.5,
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
                                  color: Colors.grey,
                                  fontSize: 10,
                                  letterSpacing: 2.5,
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Text(
                            'Say Hello to everyone.',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              letterSpacing: 2.5,
                            ),
                          );
                        }
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
            builder: (context) => GroupChatRoom(
              roomId: _roomId,
            ),
          ),
        );
      },
    );
  }
}
