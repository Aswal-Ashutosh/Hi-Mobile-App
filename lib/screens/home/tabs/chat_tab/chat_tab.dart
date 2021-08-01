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
      body: FutureBuilder<Stream<QuerySnapshot<Map<String, dynamic>>>>(
        future: FirebaseService.currentUserStreamToChats,
        builder: (context, snapshots) {
          if (snapshots.connectionState == ConnectionState.done) {
            return StreamBuilder<QuerySnapshot>(
              stream: snapshots.data,
              builder: (context, snapshots) {
                List<Widget> chatCards = [];
                if (snapshots.hasData && snapshots.data!.docs.isNotEmpty) {
                  final chats = snapshots.data?.docs;
                  chats?.forEach((element) {
                    if (element[ChatDBDocumentField.TYPE] ==
                        ChatType.ONE_TO_ONE) {
                      late String friendEmail;
                      for (final email
                          in element[ChatDBDocumentField.MEMBERS]) {
                        if (email != FirebaseService.currentUserEmail) {
                          friendEmail = email;
                        }
                      }
                      chatCards.add(ChatCardOneToOne(
                        roomId: element[ChatDBDocumentField.ROOM_ID],
                        friendEmail: friendEmail,
                      ));
                    } else {
                      chatCards.add(
                        GroupChatCard(
                          roomId: element[GroupDBDocumentField.ROOM_ID],
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
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result =
              await Navigator.pushNamed(context, GroupChatSelectionScreen.id);
          if (result == true) {
            setState(() {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Group Created Successfully.')));
            });
          }
        },
        backgroundColor: kPrimaryColor,
        child: Icon(Icons.group_add),
      ),
    );
  }
}
