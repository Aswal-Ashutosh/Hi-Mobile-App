import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/custom_widget/stream_builders/circular_profile_picture.dart';
import 'package:hi/custom_widget/stream_builders/selection_card.dart';
import 'package:hi/provider/selected_users.dart';
import 'package:hi/services/firebase_service.dart';
import 'package:provider/provider.dart';

class GroupChatSelectionScreen extends StatelessWidget {
  static const id = 'group_chat_selection_screen';
  const GroupChatSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displaySize = MediaQuery.of(context).size;
    return ChangeNotifierProvider<SelectedUsers>(
      create: (context) => SelectedUsers(),
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              Text('Create New Group'),
              Text(
                'Add members',
                style: TextStyle(fontSize: 12),
              )
            ],
          ),
          backgroundColor: kPrimaryColor,
          actions: [IconButton(onPressed: () {}, icon: Icon(Icons.search))],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Consumer<SelectedUsers>(
                builder: (context, selectedUsers, child) {
                  if (selectedUsers.isNotEmpty) {
                    List<String> users = selectedUsers.toList;
                    return SelectedUsersHorizontalBar(
                      displaySize: displaySize,
                      users: users,
                    );
                  } else {
                    return Container();
                  }
                },
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseService.currentUserStreamToFriends,
                builder: (conext, snapshot) {
                  List<SelectionCard> friendList = [];
                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    final friends = snapshot.data?.docs;
                    if (friends != null) {
                      for (final friend in friends) {
                        final friendEmail = friend['email'];
                        friendList.add(
                          SelectionCard(
                            friendEmail: friendEmail,
                          ),
                        );
                      }
                    }
                  }
                  return Expanded(
                    child: ListView(
                      children: friendList,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        floatingActionButton: Consumer<SelectedUsers>(
          builder: (context, selectedUsers, child) {
            if (selectedUsers.isNotEmpty) {
              return FloatingActionButton(
                  onPressed: () {},
                  child: Icon(Icons.done),
                  backgroundColor: kPrimaryColor);
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}

class SelectedUsersHorizontalBar extends StatelessWidget {
  const SelectedUsersHorizontalBar({
    required this.displaySize,
    required this.users,
  });

  final Size displaySize;
  final List<String> users;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: kDefaultPadding),
      height: displaySize.height * 0.12,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: kDefaultPadding / 5.0),
                child: CircularProfilePicture(
                    email: users[index], radius: displaySize.height * 0.05),
              ),
              itemCount: users.length,
            ),
          ),
          Divider()
        ],
      ),
    );
  }
}
