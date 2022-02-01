import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/constants/firestore_costants.dart';
import 'package:hi/custom_widget/stream_builders/circular_group_profile_picture.dart';
import 'package:hi/custom_widget/stream_builders/text_stream_builder.dart';
import 'package:hi/provider/selected_chats.dart';
import 'package:hi/screens/chat/group_chat/group_chat_room.dart';
import 'package:hi/screens/profile_view/group_profile_view_screen.dart';
import 'package:hi/services/encryption_service.dart';
import 'package:hi/services/firebase_service.dart';
import 'package:provider/provider.dart';

class GroupChatCard extends StatefulWidget {
  final String _roomId;
  final bool _lastMessageSeen;
  final bool _selectionMode;
  final _selectionModeManager;
  const GroupChatCard(
      {required final String roomId,
      required final bool lastMessageSeen,
      required final bool selectionMode,
      required final selectionModeManager})
      : _roomId = roomId,
        _lastMessageSeen = lastMessageSeen,
        _selectionMode = selectionMode,
        _selectionModeManager = selectionModeManager;

  @override
  _GroupChatCardState createState() => _GroupChatCardState();
}

class _GroupChatCardState extends State<GroupChatCard> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseService.getStreamToUserChatRef(roomId: widget._roomId),
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data!.exists) {
            final doc = snapshot.data;
            final bool isRemoved = doc?[ChatDocumentField.REMOVED];
            final bool isDeleted = doc?[ChatDocumentField.DELETED];
            final bool isDeletable = isRemoved || isDeleted;
            return InkWell(
              child: Container(
                color: isSelected
                    ? Color(0x552EA043)
                    : Theme.of(context).scaffoldBackgroundColor,
                padding: const EdgeInsets.all(kDefaultPadding / 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (isRemoved)
                      GroupProfileImage(
                        roomId: widget._roomId,
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'You need to be a member to see group profile.'),
                          ),
                        ),
                      ),
                    if (isDeleted)
                      GroupProfileImage(
                        roomId: widget._roomId,
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('This group no longer exist.'),
                          ),
                        ),
                      ),
                    if (isDeleted == false && isRemoved == false)
                      GroupProfileImage(
                        roomId: widget._roomId,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupProfileScreen(
                              roomId: widget._roomId,
                            ),
                          ),
                        ),
                      ),
                    SizedBox(width: kDefaultPadding / 2.0),
                    if (isRemoved || isDeleted)
                      Flexible(
                        child: TextStreamBuilder(
                          stream: FirebaseService.getStreamToGroupData(
                              roomId: widget._roomId),
                          key: ChatDBDocumentField.GROUP_NAME,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                            letterSpacing: 2.5,
                          ),
                        ),
                      ),
                    if (isRemoved == false && isDeleted == false)
                      Flexible(
                        child: BodyIfMember(
                          roomId: widget._roomId,
                          lastMessageSeen: widget._lastMessageSeen,
                        ),
                      ),
                  ],
                ),
              ),
              onTap: widget._selectionMode
                  ? isDeletable
                      ? () {
                          if (isSelected) {
                            Provider.of<SelectedChats>(context, listen: false)
                                .removeChat(roomId: widget._roomId);

                            if (Provider.of<SelectedChats>(context,
                                    listen: false)
                                .isEmpty) widget._selectionModeManager(false);
                          } else {
                            Provider.of<SelectedChats>(context, listen: false)
                                .addChat(roomId: widget._roomId);
                          }
                          setState(() {
                            isSelected = !isSelected;
                          });
                        }
                      : () => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Active group chat can\'t be deleted.'),
                            ),
                          )
                  : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GroupChatRoom(
                            roomId: widget._roomId,
                          ),
                        ),
                      ),
              onLongPress: widget._selectionMode
                  ? null
                  : isDeletable
                      ? () {
                          Provider.of<SelectedChats>(context, listen: false)
                              .addChat(roomId: widget._roomId);
                          setState(() {
                            isSelected = true;
                          });
                          widget._selectionModeManager(true);
                        }
                      : () => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Active group chat can\'t be deleted.'),
                            ),
                          ),
            );
          } else {
            return Container(
              padding: const EdgeInsets.all(kDefaultPadding / 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularGroupProfilePicture(
                      roomId: widget._roomId,
                      radius: kDefualtBorderRadius * 1.5),
                  SizedBox(width: kDefaultPadding / 2.0),
                  Flexible(
                    child: TextStreamBuilder(
                      stream: FirebaseService.getStreamToGroupData(
                          roomId: widget._roomId),
                      key: ChatDBDocumentField.GROUP_NAME,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        letterSpacing: 2.5,
                      ),
                    ),
                  )
                ],
              ),
            );
          }
        });
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
