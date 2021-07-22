import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/custom_widget/stream_builders/friend_card.dart';
import 'package:hi/services/firebase_service.dart';

class MyFriends extends StatelessWidget {
  const MyFriends();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: (){}, child: Icon(Icons.search), backgroundColor: kPrimaryColor),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseService.currentUserStreamToFriends,
        builder: (conext, snapshot) {
          List<FriendCard> friendList = [];
          if(snapshot.hasData && snapshot.data!.docs.isNotEmpty){
            final friends = snapshot.data?.docs;
            if(friends != null){
              for(final friend in friends){
                final friendEmail = friend['email'];
                friendList.add(
                  FriendCard(friendEmail: friendEmail,)
                );
              }
            }
          }
          return ListView(
            children: friendList,
          );
        },
      ),
    );
  }
}