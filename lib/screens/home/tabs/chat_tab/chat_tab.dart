import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/constants/firestore_costants.dart';
import 'package:hi/custom_widget/progressHud/progress_hud.dart';
import 'package:hi/provider/selected_chats.dart';
import 'package:hi/screens/group/group_chat_selection_screen.dart';
import 'package:hi/screens/home/tabs/chat_tab/components/chat_card_one_to_one.dart';
import 'package:hi/screens/home/tabs/chat_tab/components/group_chat_card.dart';
import 'package:hi/services/firebase_service.dart';
import 'package:provider/provider.dart';

class ChatTab extends StatefulWidget {
  @override
  _ChatTabState createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  bool selectionMode = false;
  void selectionModeManager(bool condition) {
    setState(() {
      selectionMode = condition;
    });
  }

  bool isLoading = false;
  void setLoading(bool condition) {
    setState(() {
      isLoading = condition;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SelectedChats(),
      child: ProgressHUD(
        showIndicator: isLoading,
        child: Scaffold(
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseService.currentUserStreamToChats,
            builder: (context, snapshots) {
              if (snapshots.hasData &&
                  snapshots.data != null &&
                  snapshots.data!.docs.isNotEmpty) {
                final chats = snapshots.data?.docs;
                List<String> roomId = [];

                if (chats != null)
                  for (final chat in chats) roomId.add(chat.id);

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
                          for (final email
                              in element[ChatDBDocumentField.MEMBERS])
                            if (email != FirebaseService.currentUserEmail)
                              friendEmail = email;

                          chatCards.add(
                            ChatCardOneToOne(
                              roomId: element[ChatDBDocumentField.ROOM_ID],
                              friendEmail: friendEmail,
                              lastMessageSeen: lastMessageSeen.containsKey(
                                FirebaseService.currentUserEmail,
                              ),
                              selectionMode: selectionMode,
                              selectionModeManager: selectionModeManager,
                            ),
                          );
                        } else {
                          chatCards.add(
                            GroupChatCard(
                              roomId: element[ChatDBDocumentField.ROOM_ID],
                              lastMessageSeen: lastMessageSeen.containsKey(
                                FirebaseService.currentUserEmail,
                              ),
                              selectionMode: selectionMode,
                              selectionModeManager: selectionModeManager,
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
          floatingActionButton: selectionMode
              ? Consumer<SelectedChats>(
                  builder: (context, selectedChats, child) {
                    return FloatingActionButton(
                      onPressed: () async {
                        setLoading(true);
                        await selectedChats.deleteChats();
                        setLoading(false);
                        selectionModeManager(false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Chats deleted successfully.'),
                          ),
                        );
                      },
                      child: Icon(Icons.delete),
                      backgroundColor: Colors.red,
                    );
                  },
                )
              : FloatingActionButton(
                  onPressed: () async {
                    final result = await Navigator.pushNamed(
                        context, GroupChatSelectionScreen.id);
                    if (result == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Group Created Successfully.'),
                        ),
                      );
                    }
                  },
                  backgroundColor: kPrimaryColor,
                  child: Icon(Icons.group_add),
                ),
        ),
      ),
    );
  }
}
