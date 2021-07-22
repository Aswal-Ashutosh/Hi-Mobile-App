import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hi/custom_widget/stream_builders/friend_request_card.dart';
import 'package:hi/services/firebase_service.dart';

class RequestsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseService.currentUserStreamToFirendRequests,
        builder: (conext, snapshot) {
          List<FriendRequestCard> friendRequests = [];
          if(snapshot.hasData && snapshot.data!.docs.isNotEmpty){
            final requests = snapshot.data?.docs;
            if(requests != null){
              for(final request in requests){
                final senderEmail = request['sender_email'];
                final date = request['date'];
                final time = request['time'];
                friendRequests.add(
                  FriendRequestCard(senderEmail: senderEmail, date: date, time: time)
                );
              }
            }
          }
          return ListView(
            children: friendRequests,
          );
        },
      ),
    );
  }
}