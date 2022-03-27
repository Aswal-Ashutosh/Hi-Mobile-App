import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hi/constants/firestore_constants.dart';
import 'package:hi/screens/home/tabs/chat_tab/components/chat_card_one_to_one.dart';
import 'package:hi/screens/home/tabs/chat_tab/components/group_chat_card.dart';
import 'package:hi/services/firebase_service.dart';

class ChatCard extends StatelessWidget {
  const ChatCard({required final String roomId, required final bool selectionMode, required final selectionModeManager}) : _roomId = roomId, _selectionMode = selectionMode, _selectionModeManager = selectionModeManager;

  final String _roomId;
  final bool _selectionMode;
  final _selectionModeManager;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseService.getStreamToChatRoomDoc(roomId: _roomId),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final docData = snapshot.data;
          final Map<dynamic, dynamic> lastMessageSeen = docData?[ChatDBDocumentField.LAST_MESSAGE_SEEN];
          if (docData?[ChatDBDocumentField.TYPE] == ChatType.ONE_TO_ONE) {
            late String friendEmail;
            for (final email in docData?[ChatDBDocumentField.MEMBERS])
              if (email != FirebaseService.currentUserEmail)
                friendEmail = email;
            return ChatCardOneToOne(
                roomId: docData?[ChatDBDocumentField.ROOM_ID],
                friendEmail: friendEmail,
                lastMessageSeen: lastMessageSeen.containsKey(
                  FirebaseService.currentUserEmail,
                ),
                selectionMode: _selectionMode,
                selectionModeManager: _selectionModeManager,
              );
          } else {
            return GroupChatCard(
                roomId: docData?[ChatDBDocumentField.ROOM_ID],
                lastMessageSeen: lastMessageSeen.containsKey(
                  FirebaseService.currentUserEmail,
                ),
                selectionMode: _selectionMode,
                selectionModeManager: _selectionModeManager,
              );
          }
        }else{
          return Container();
        }
      },
    );
  }
}
