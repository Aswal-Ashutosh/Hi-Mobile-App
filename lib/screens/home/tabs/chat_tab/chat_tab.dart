import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/constants/firestore_costants.dart';
import 'package:hi/screens/group/group_chat_selection_screen.dart';
import 'package:hi/screens/home/tabs/chat_tab/components/chat_card_one_to_one.dart';
import 'package:hi/screens/home/tabs/chat_tab/components/group_chat_card.dart';
import 'package:hi/services/firebase_service.dart';

class ChatTab extends StatefulWidget {
  @override
  _ChatTabState createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseService.currentUserStreamToChats,
        builder: (context, snapshots) {
          List<String> chats = [];
          if (snapshots.hasData &&
              snapshots.data != null &&
              snapshots.data!.docs.isNotEmpty) {
            final chats = snapshots.data?.docs;
            List<String> roomId = [];

            if (chats != null) for (final chat in chats) roomId.add(chat.id);

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseService.getStreamToChatDBWhereRoomIdIn(
                  roomId: roomId),
              builder: (context, snapshots) {
                List<Widget> chatCards = [];
                if (snapshots.hasData &&
                    snapshots.data != null &&
                    snapshots.data!.docs.isNotEmpty) {
                  final chats = snapshots.data?.docs;
                  chats?.forEach((element) {
                    final Map<dynamic, dynamic> lastMessageSeen =
                        element[ChatDBDocumentField.LAST_MESSAGE_SEEN];
                    if (element[ChatDBDocumentField.TYPE] ==
                        ChatType.ONE_TO_ONE) {
                      late String friendEmail;
                      for (final email in element[ChatDBDocumentField.MEMBERS])
                        if (email != FirebaseService.currentUserEmail)
                          friendEmail = email;

                      chatCards.add(
                        ChatCardOneToOne(
                          roomId: element[ChatDBDocumentField.ROOM_ID],
                          friendEmail: friendEmail,
                          lastMessageSeen: lastMessageSeen
                              .containsKey(FirebaseService.currentUserEmail),
                        ),
                      );
                    } else {
                      chatCards.add(
                        GroupChatCard(
                          roomId: element[ChatDBDocumentField.ROOM_ID],
                          lastMessageSeen: lastMessageSeen
                              .containsKey(FirebaseService.currentUserEmail),
                        ),
                      );
                    }
                  });
                }
                return ListView(
                  children: chatCards,
                );
              },
            );
          } else {
            return Center(
              child: Text(
                'No chats available',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result =
              await Navigator.pushNamed(context, GroupChatSelectionScreen.id);
          if (result == true) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Group Created Successfully.')));
          }
        },
        backgroundColor: kPrimaryColor,
        child: Icon(Icons.group_add),
      ),
    );
  }
}
