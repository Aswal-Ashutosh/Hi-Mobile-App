import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/custom_widget/progressHud/progress_hud.dart';
import 'package:hi/custom_widget/stream_builders/circular_profile_picture.dart';
import 'package:hi/custom_widget/stream_builders/selection_card.dart';
import 'package:hi/provider/selected_users.dart';
import 'package:hi/services/firebase_service.dart';
import 'package:provider/provider.dart';

class GroupChatAddMemberScreen extends StatefulWidget {
  final String _roomId;
  const GroupChatAddMemberScreen({required final String roomId})
      : _roomId = roomId;
  @override
  _GroupChatAddMemberScreenState createState() =>
      _GroupChatAddMemberScreenState();
}

class _GroupChatAddMemberScreenState extends State<GroupChatAddMemberScreen> {
  bool isLoading = false;
  void setLoading(bool condition) {
    setState(() {
      isLoading = condition;
    });
  }

  @override
  Widget build(BuildContext context) {
    final displaySize = MediaQuery.of(context).size;
    return ChangeNotifierProvider<SelectedUsers>(
      create: (context) => SelectedUsers(),
      child: ProgressHUD(
        showIndicator: isLoading,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Add Members'),
            backgroundColor: kPrimaryColor,
            actions: [IconButton(onPressed: () {}, icon: Icon(Icons.search))],
          ),
          body: SafeArea(
            child: FutureBuilder<Set<String>>(
              future: FirebaseService.getGroupMembers(roomId: widget._roomId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError || snapshot.data == null) {
                    return Center(
                      child: Text(
                        'Something went wrong!',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  } else {
                    final Set<String> alreadyMembers =
                        snapshot.data as Set<String>;
                    return Column(
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
                            if (snapshot.hasData &&
                                snapshot.data!.docs.isNotEmpty) {
                              final friends = snapshot.data?.docs;
                              if (friends != null) {
                                for (final friend in friends) {
                                  final friendEmail = friend['email'];
                                  if (alreadyMembers.contains(friendEmail) ==
                                      false) {
                                    friendList.add(
                                      SelectionCard(
                                        friendEmail: friendEmail,
                                      ),
                                    );
                                  }
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
                    );
                  }
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
          floatingActionButton: Consumer<SelectedUsers>(
            builder: (context, selectedUsers, child) {
              if (selectedUsers.isNotEmpty) {
                return FloatingActionButton(
                    onPressed: () async {
                      setLoading(true);
                      await FirebaseService.addMembersInGroup(
                          roomId: widget._roomId,
                          newMembers: selectedUsers.toList);
                      setLoading(false);
                      Navigator.pop(context, true);
                    },
                    child: Icon(Icons.done),
                    backgroundColor: kPrimaryColor);
              } else {
                return Container();
              }
            },
          ),
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
