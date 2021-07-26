import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hi/constants/firestore_costants.dart';
import 'package:hi/screens/home/tabs/chat_tab/components/chat_card_one_to_one.dart';
import 'package:hi/services/firebase_service.dart';

class ChatTab extends StatelessWidget {
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
                  chats?.forEach((element){
                    late String friendEmail;
                    for(final email in element[ChatDBDocumentField.MEMBERS]){
                      if(email != FirebaseService.currentUserEmail){
                        friendEmail = email;
                      }
                    }
                    chatCards.add(
                      ChatCardOneToOne(
                        roomId:element[ChatDBDocumentField.ROOM_ID],
                        friendEmail: friendEmail,
                      )
                    );
                  });
                }
                return ListView(
                  children: chatCards,
                );
              },
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
