import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/constants/firestore_constants.dart';
import 'package:hi/custom_widget/stream_builders/circular_profile_picture.dart';
import 'package:hi/custom_widget/stream_builders/conditional_stream_builder.dart';
import 'package:hi/custom_widget/stream_builders/online_indicator_dot.dart';
import 'package:hi/custom_widget/stream_builders/text_stream_builder.dart';
import 'package:hi/provider/selected_chats.dart';
import 'package:hi/screens/chat/one_to_one/chat_room.dart';
import 'package:hi/screens/profile_view/user_profile_view_screen.dart';
import 'package:hi/services/encryption_service.dart';
import 'package:hi/services/firebase_service.dart';
import 'package:provider/provider.dart';

class ChatCardOneToOne extends StatefulWidget {
  final String _roomId;
  final String _friendEmail;
  final bool _lastMessageSeen;
  final bool _selectionMode;
  final _selectionModeManager;
  const ChatCardOneToOne(
      {required final String roomId,
      required final String friendEmail,
      required final bool lastMessageSeen,
      required final selectionMode,
      required final selectionModeManager})
      : _roomId = roomId,
        _friendEmail = friendEmail,
        _lastMessageSeen = lastMessageSeen,
        _selectionMode = selectionMode,
        _selectionModeManager = selectionModeManager;

  @override
  _ChatCardOneToOneState createState() => _ChatCardOneToOneState();
}

class _ChatCardOneToOneState extends State<ChatCardOneToOne> {
  bool isSelected = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        color: isSelected
            ? Color(0x552EA043)
            : Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.all(kDefaultPadding / 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      UserProfileScreen(userEmail: widget._friendEmail),
                ),
              ),
              child: CircularProfilePicture(
                email: widget._friendEmail,
                radius: kDefaultBorderRadius * 1.5,
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
                            email: widget._friendEmail),
                        key: UserDocumentField.DISPLAY_NAME,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          letterSpacing: 2.5,
                        ),
                      ),
                      SizedBox(width: kDefaultPadding / 4.0),
                      ConditionalStreamBuilder(
                        stream: FirebaseService.getStreamToFriendDoc(
                            email: widget._friendEmail),
                        childIfExist:
                            OnlineIndicatorDot(email: widget._friendEmail),
                        childIfDoNotExist: Container(),
                      ),
                      if (widget._lastMessageSeen == false) Spacer(),
                      if (widget._lastMessageSeen == false)
                        Icon(Icons.message_rounded, color: Colors.green),
                    ],
                  ),
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseService.getStreamToChatRoomDoc(
                        roomId: widget._roomId),
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
                                        color: widget._lastMessageSeen
                                            ? Colors.grey
                                            : Colors.blueGrey,
                                        fontSize: 12,
                                        letterSpacing: 2.5,
                                        fontWeight: widget._lastMessageSeen
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
                                color: widget._lastMessageSeen
                                    ? Colors.grey
                                    : Colors.blueGrey,
                                fontSize: 10,
                                letterSpacing: 2.5,
                                fontWeight: widget._lastMessageSeen
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      } else {
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
      onTap: widget._selectionMode
          ? () {
              if (isSelected) {
                Provider.of<SelectedChats>(context, listen: false)
                    .removeChat(roomId: widget._roomId);

                if (Provider.of<SelectedChats>(context, listen: false).isEmpty)
                  widget._selectionModeManager(false);
              } else {
                Provider.of<SelectedChats>(context, listen: false)
                    .addChat(roomId: widget._roomId);
              }
              setState(() {
                isSelected = !isSelected;
              });
            }
          : () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatRoom(
                      roomId: widget._roomId, friendEmail: widget._friendEmail),
                ),
              ),
      onLongPress: widget._selectionMode
          ? null
          : () {
              Provider.of<SelectedChats>(context, listen: false)
                  .addChat(roomId: widget._roomId);
              setState(() {
                isSelected = true;
              });
              widget._selectionModeManager(true);
            },
    );
  }
}
