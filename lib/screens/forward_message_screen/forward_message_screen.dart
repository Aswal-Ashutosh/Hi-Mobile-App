import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/constants/firestore_costants.dart';
import 'package:hi/custom_widget/progressHud/progress_hud.dart';
import 'package:hi/custom_widget/stream_builders/circular_group_profile_picture.dart';
import 'package:hi/custom_widget/stream_builders/circular_profile_picture.dart';
import 'package:hi/provider/helper/chat.dart';
import 'package:hi/provider/helper/message.dart';
import 'package:hi/provider/selected_forward_message_chats.dart';
import 'package:hi/screens/forward_message_screen/components/forward_message_chat_card.dart';
import 'package:hi/services/firebase_service.dart';
import 'package:provider/provider.dart';

class ForwardMessageScreen extends StatefulWidget {
  final List<Message> messages;

  const ForwardMessageScreen({required this.messages});

  @override
  _ForwardMessageScreenState createState() => _ForwardMessageScreenState();
}

class _ForwardMessageScreenState extends State<ForwardMessageScreen> {
  bool isLoading = false;
  void setLoading(bool condition) {
    setState(() {
      isLoading = condition;
    });
  }

  @override
  Widget build(BuildContext context) {
    final displaySize = MediaQuery.of(context).size;
    return ChangeNotifierProvider<SelectedForwardMessageChats>(
      create: (context) => SelectedForwardMessageChats(),
      child: ProgressHUD(
        showIndicator: isLoading,
        child: Scaffold(
          appBar: AppBar(
            title: Column(
              children: [
                Text('Forward Messages'),
                Text(
                  'select chats',
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
                Consumer<SelectedForwardMessageChats>(
                  builder: (context, selectedChats, child) {
                    if (selectedChats.isNotEmpty) {
                      List<Chat> chats = selectedChats.toList;
                      return SelectedUsersHorizontalBar(
                        displaySize: displaySize,
                        chats: chats,
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseService.currentUserStreamToAllChats,
                  builder: (conext, snapshot) {
                    List<ForwardMessageChatCards> forwardChatCards = [];
                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      final chats = snapshot.data?.docs;
                      if (chats != null) {
                        for (final x in chats) {
                          Map<dynamic, dynamic> chat =
                              x.data() as Map<dynamic, dynamic>;
                          if (chat[ChatDocumentField.VISIBILITY] == false &&
                              chat.containsKey(ChatDocumentField.DELETED))
                            continue;
                          forwardChatCards.add(ForwardMessageChatCards(
                              roomId: chat[ChatDocumentField.ROOM_ID]));
                        }
                      }
                    }
                    return Expanded(
                      child: ListView(
                        children: forwardChatCards,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          floatingActionButton: Consumer<SelectedForwardMessageChats>(
            builder: (context, selectedChats, child) {
              if (selectedChats.isNotEmpty) {
                return FloatingActionButton(
                    onPressed: () async {
                    setLoading(true);
                     await FirebaseService.forwardMessages(messages: widget.messages, chats: selectedChats.toList);
                     setLoading(false);
                     Navigator.pop(context, true);
                    },
                    child: Icon(Icons.send),
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
    required this.chats,
  });

  final Size displaySize;
  final List<Chat> chats;

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
                child: chats[index].type == ChatType.ONE_TO_ONE
                    ? CircularProfilePicture(
                        email: chats[index].friendEmail as String,
                        radius: displaySize.height * 0.05)
                    : CircularGroupProfilePicture(roomId: chats[index].roomId),
              ),
              itemCount: chats.length,
            ),
          ),
          Divider()
        ],
      ),
    );
  }
}
