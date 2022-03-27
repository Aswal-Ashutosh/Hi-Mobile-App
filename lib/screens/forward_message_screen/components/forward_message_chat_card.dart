import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/constants/firestore_constants.dart';
import 'package:hi/custom_widget/stream_builders/circular_group_profile_picture.dart';
import 'package:hi/custom_widget/stream_builders/circular_profile_picture.dart';
import 'package:hi/custom_widget/stream_builders/text_stream_builder.dart';
import 'package:hi/provider/helper/chat.dart';
import 'package:hi/provider/selected_forward_message_chats.dart';
import 'package:hi/services/firebase_service.dart';
import 'package:provider/provider.dart';

class ForwardMessageChatCards extends StatelessWidget {
  const ForwardMessageChatCards({
    required final String roomId,
  }) : _roomId = roomId;

  final String _roomId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseService.getStreamToChatRoomDoc(roomId: _roomId),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final docData = snapshot.data;
          if (docData?[ChatDBDocumentField.TYPE] == ChatType.ONE_TO_ONE) {
            late String friendEmail;
            for (final email in docData?[ChatDBDocumentField.MEMBERS])
              if (email != FirebaseService.currentUserEmail)
                friendEmail = email;
            return OneToOneChatBody(
              roomId: docData?[ChatDBDocumentField.ROOM_ID],
              friendEmail: friendEmail,
            );
          } else {
            return GroupChatBody(
              roomId: docData?[ChatDBDocumentField.ROOM_ID],
            );
          }
        } else {
          return Container();
        }
      },
    );
  }
}

class OneToOneChatBody extends StatefulWidget {
  final String _roomId;
  final String _friendEmail;
  const OneToOneChatBody({
    required final String roomId,
    required final String friendEmail,
  })  : _roomId = roomId,
        _friendEmail = friendEmail;
  @override
  _OneToOneChatBodyState createState() => _OneToOneChatBodyState();
}

class _OneToOneChatBodyState extends State<OneToOneChatBody> {
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
            CircularProfilePicture(
              email: widget._friendEmail,
              radius: kDefaultBorderRadius * 1.5,
            ),
            SizedBox(width: kDefaultPadding / 2.0),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      if (isSelected)
                        ClipOval(
                            child: Container(
                                child: Icon(Icons.done,
                                    color: Colors.white, size: 20),
                                color: Colors.green))
                    ],
                  ),
                  TextStreamBuilder(
                    stream: FirebaseService.getStreamToUserData(
                        email: widget._friendEmail),
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
        setState(() {
          if (isSelected) {
            Provider.of<SelectedForwardMessageChats>(context, listen: false)
                .removeChat(roomId: widget._roomId);
          } else {
            Provider.of<SelectedForwardMessageChats>(context, listen: false)
                .addChat(
              chat: Chat(
                  roomId: widget._roomId,
                  type: ChatType.ONE_TO_ONE,
                  friendEmail: widget._friendEmail),
            );
          }
          isSelected = !isSelected;
        });
      },
    );
  }
}

class GroupChatBody extends StatefulWidget {
  final String _roomId;
  const GroupChatBody({
    required final String roomId,
  }) : _roomId = roomId;

  @override
  _GroupChatBodyState createState() => _GroupChatBodyState();
}

class _GroupChatBodyState extends State<GroupChatBody> {
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
            CircularGroupProfilePicture(
              roomId: widget._roomId,
              radius: kDefaultBorderRadius * 1.5,
            ),
            SizedBox(width: kDefaultPadding / 2.0),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextStreamBuilder(
                        stream: FirebaseService.getStreamToGroupData(
                            roomId: widget._roomId),
                        key: ChatDBDocumentField.GROUP_NAME,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          letterSpacing: 2.5,
                        ),
                      ),
                      if (isSelected)
                        ClipOval(
                          child: Container(
                            child:
                                Icon(Icons.done, color: Colors.white, size: 20),
                            color: Colors.green,
                          ),
                        )
                    ],
                  ),
                  TextStreamBuilder(
                    stream: FirebaseService.getStreamToGroupData(
                        roomId: widget._roomId),
                    key: ChatDBDocumentField.GROUP_ABOUT,
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
        setState(() {
          if (isSelected) {
            Provider.of<SelectedForwardMessageChats>(context, listen: false)
                .removeChat(roomId: widget._roomId);
          } else {
            Provider.of<SelectedForwardMessageChats>(context, listen: false)
                .addChat(
                    chat: Chat(roomId: widget._roomId, type: ChatType.GROUP));
          }
          isSelected = !isSelected;
        });
      },
    );
  }
}
