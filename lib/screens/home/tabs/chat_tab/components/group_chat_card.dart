import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/constants/firestore_costants.dart';
import 'package:hi/custom_widget/stream_builders/circular_group_profile_picture.dart';
import 'package:hi/custom_widget/stream_builders/text_stream_builder.dart';
import 'package:hi/screens/chat/group_chat/group_chat_room.dart';
import 'package:hi/screens/profile_view/group_profile_view_screen.dart';
import 'package:hi/services/encryption_service.dart';
import 'package:hi/services/firebase_service.dart';

class GroupChatCard extends StatelessWidget {
  final String _roomId;
  final bool _lastMessageSeen;
  const GroupChatCard(
      {required final String roomId, required final bool lastMessageSeen})
      : _roomId = roomId,
        _lastMessageSeen = lastMessageSeen;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        padding: const EdgeInsets.all(kDefaultPadding / 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseService.getStreamToUserChatRef(roomId: _roomId),
              builder: (context, snapshot) {
                if (snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data!.exists) {
                  final doc = snapshot.data;
                  late void Function()? onTap;
                  if (doc![ChatDocumentField.REMOVED]) {
                    onTap = () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'You need to be a member to see group profile.'),
                          ),
                        );
                  } else if (doc[ChatDBDocumentField.DELETED]) {
                    onTap = () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('This group no longer exist.'),
                          ),
                        );
                  } else {
                    onTap = () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupProfileScreen(
                              roomId: _roomId,
                            ),
                          ),
                        );
                  }
                  return GroupProfileImage(roomId: _roomId, onTap: onTap);
                } else {
                  return CircleAvatar(
                    child: Icon(
                      Icons.group,
                      color: Colors.grey,
                      size: kDefualtBorderRadius * 3,
                    ),
                    backgroundColor: Colors.blueGrey,
                    radius: kDefualtBorderRadius * 3,
                  );
                }
              },
            ),
            SizedBox(width: kDefaultPadding / 2.0),
            Flexible(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseService.getStreamToUserChatRef(roomId: _roomId),
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data != null &&
                      snapshot.data!.exists) {
                    final doc = snapshot.data;
                    if (doc![ChatDocumentField.REMOVED] ||
                        doc[ChatDBDocumentField.DELETED])
                      return TextStreamBuilder(
                        stream: FirebaseService.getStreamToGroupData(
                            roomId: _roomId),
                        key: ChatDBDocumentField.GROUP_NAME,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          letterSpacing: 2.5,
                        ),
                      );
                    else
                      return BodyIfMember(
                          roomId: _roomId, lastMessageSeen: _lastMessageSeen);
                  } else {
                    return Text('Loading...',
                        style: TextStyle(color: Colors.grey));
                  }
                },
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

class GroupProfileImage extends StatelessWidget {
  const GroupProfileImage({
    Key? key,
    required String roomId,
    required final void Function()? onTap,
  })  : _roomId = roomId,
        _onTap = onTap,
        super(key: key);

  final String _roomId;
  final void Function()? _onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _onTap,
      child: CircularGroupProfilePicture(
        roomId: _roomId,
        radius: kDefualtBorderRadius * 1.5,
      ),
    );
  }
}

class BodyIfMember extends StatelessWidget {
  const BodyIfMember({
    Key? key,
    required String roomId,
    required bool lastMessageSeen,
  })  : _roomId = roomId,
        _lastMessageSeen = lastMessageSeen,
        super(key: key);

  final String _roomId;
  final bool _lastMessageSeen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TextStreamBuilder(
              stream: FirebaseService.getStreamToGroupData(roomId: _roomId),
              key: ChatDBDocumentField.GROUP_NAME,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 15,
                letterSpacing: 2.5,
              ),
            ),
            if (_lastMessageSeen == false) Spacer(),
            if (_lastMessageSeen == false)
              Icon(Icons.message_rounded, color: Colors.green),
          ],
        ),
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseService.getStreamToGroupData(roomId: _roomId),
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
                        color: _lastMessageSeen ? Colors.grey : Colors.blueGrey,
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
                return Text(
                  'Say Hello to everyone.',
                  style: TextStyle(
                    color: _lastMessageSeen ? Colors.grey : Colors.blueGrey,
                    fontSize: 12,
                    letterSpacing: 2.5,
                    fontWeight:
                        _lastMessageSeen ? FontWeight.normal : FontWeight.bold,
                  ),
                );
              }
            } else {
              //TODO: Add Shimmer
              return Text('Loading...', style: TextStyle(color: Colors.grey));
            }
          },
        ),
      ],
    );
  }
}
