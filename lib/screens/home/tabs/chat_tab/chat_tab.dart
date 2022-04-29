import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/constants/firestore_constants.dart';
import 'package:hi/custom_widget/progressHud/progress_hud.dart';
import 'package:hi/provider/selected_chats.dart';
import 'package:hi/screens/group/group_chat_selection_screen.dart';
import 'package:hi/screens/home/tabs/chat_tab/components/chat_card.dart';
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
                List<String> rooms = [];

                if (chats != null) for (final chat in chats) rooms.add(chat.id);

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseService.getStreamToChatDBWhereRoomIdIn(
                      rooms: rooms),
                  builder: (context, snapshots) {
                    List<ChatCard> chatCards = [];

                    if (snapshots.hasData &&
                        snapshots.data != null &&
                        snapshots.data!.docs.isNotEmpty) {
                      final roomDocs = snapshots.data?.docs;
                      if (roomDocs != null) {
                        for (final doc in roomDocs) {
                          chatCards.add(
                            ChatCard(
                              roomId: doc[ChatDBDocumentField.ROOM_ID],
                              selectionMode: selectionMode,
                              selectionModeManager: selectionModeManager,
                            ),
                          );
                        }
                      }
                    }
                    return ListView(children: chatCards);
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
