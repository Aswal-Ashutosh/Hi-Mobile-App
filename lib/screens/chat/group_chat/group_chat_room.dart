import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/constants/firestore_costants.dart';
import 'package:hi/custom_widget/progressHud/progress_hud.dart';
import 'package:hi/custom_widget/stream_builders/circular_group_profile_picture.dart';
import 'package:hi/custom_widget/stream_builders/text_stream_builder.dart';
import 'package:hi/provider/helper/message.dart';
import 'package:hi/provider/selected_messages.dart';
import 'package:hi/screens/chat/group_chat/components/group_image_message.dart';
import 'package:hi/screens/chat/group_chat/components/group_message_text_field.dart';
import 'package:hi/screens/chat/group_chat/components/group_text_message.dart';
import 'package:hi/screens/forward_message_screen/forward_message_screen.dart';
import 'package:hi/screens/profile_view/group_profile_view_screen.dart';
import 'package:hi/services/encryption_service.dart';
import 'package:hi/services/firebase_service.dart';
import 'package:provider/provider.dart';
import 'dart:math' as Math;

class GroupChatRoom extends StatelessWidget {
  final String _roomId;

  GroupChatRoom({required final String roomId}) : _roomId = roomId;
  @override
  Widget build(BuildContext context) {
    return MainBody(roomId: _roomId);
  }
}

class MainBody extends StatefulWidget {
  const MainBody({
    Key? key,
    required String roomId,
  })  : _roomId = roomId,
        super(key: key);

  final String _roomId;

  @override
  _MainBodyState createState() => _MainBodyState();
}

class _MainBodyState extends State<MainBody> {
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
      create: (context) => SelectedMessages(),
      child: ProgressHUD(
        showIndicator: isLoading,
        child: Scaffold(
          appBar: AppBar(
            title: selectionMode == false
                ? StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseService.getStreamToUserChatRef(
                        roomId: widget._roomId),
                    builder: (context, snapshot) {
                      if (snapshot.hasData &&
                          snapshot.data != null &&
                          snapshot.data!.exists) {
                        final doc = snapshot.data;
                        late void Function()? onTap;
                        if (doc![ChatDocumentField.REMOVED]) {
                          onTap =
                              () => ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'You need to be a member to see group profile.'),
                                    ),
                                  );
                        } else if (doc[ChatDBDocumentField.DELETED]) {
                          onTap = () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('This group no longer exist.'),
                                ),
                              );
                        } else {
                          onTap = () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GroupProfileScreen(
                                    roomId: widget._roomId,
                                  ),
                                ),
                              );
                        }
                        return AppBarTitle(
                          roomId: widget._roomId,
                          onTap: onTap,
                        );
                      } else {
                        return Text('Loading...',
                            style: TextStyle(color: Colors.grey));
                      }
                    },
                  )
                : null,
            actions: selectionMode
                ? [
                    Consumer<SelectedMessages>(
                      builder: (context, selectedMessages, _) {
                        return IconButton(
                          onPressed: () async {
                            final result = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Delete selected messages?'),
                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context, true);
                                    },
                                    child: Text('Delete for me'),
                                  ),
                                  if (selectedMessages.canBeDeletedForEveryone)
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.pop(context, false);
                                      },
                                      child: Text('Delete for everyone'),
                                    ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Cancel'),
                                  ),
                                ],
                              ),
                            );

                            if (result == true) {
                              //Delete for me
                              setLoading(true);
                              await selectedMessages
                                  .deleteSelectedMessageForCurrentUser(
                                      roomId: widget._roomId);
                              setLoading(false);
                              selectionModeManager(false);
                            } else if (result == false) {
                              //Delete for every one
                              setLoading(true);
                              await selectedMessages
                                  .deleteSelectedMessageForEveryOne(
                                      roomId: widget._roomId);
                              setLoading(false);
                              selectionModeManager(false);
                            }
                          },
                          icon: Icon(Icons.delete),
                        );
                      },
                    ),
                    Consumer<SelectedMessages>(
                      builder: (context, selectedMessages, _) {
                        return IconButton(
                          onPressed: () async {
                            List<Message> messages = selectedMessages.toList
                              ..sort(
                                (a, b) => a.timestamp.compareTo(b.timestamp),
                              );
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ForwardMessageScreen(messages: messages),
                              ),
                            );
                            if (result == true) {
                              selectedMessages.clear();
                              selectionModeManager(false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Messages forwarded successfully.'),
                                ),
                              );
                            }
                          },
                          icon: Transform(
                            transform: Matrix4.rotationY(Math.pi),
                            alignment: Alignment.center,
                            child: Icon(Icons.reply),
                          ),
                        );
                      },
                    ),
                  ]
                : null,
            backgroundColor: kPrimaryColor,
          ),
          body: SafeArea(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseService.getStreamToUserChatRef(
                  roomId: widget._roomId),
              builder: (context, snapshot) {
                if (snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data!.exists) {
                  final doc = snapshot.data;
                  if (doc![ChatDocumentField.REMOVED]) {
                    return BodyIfNotMember(
                      roomId: widget._roomId,
                      removedAt: doc[ChatDocumentField.REMOVED_AT],
                      selectionMode: selectionMode,
                      selectionModeManager: selectionModeManager,
                    );
                  } else {
                    return BodyIfMember(
                      roomId: widget._roomId,
                      groupDeleted: doc[ChatDBDocumentField.DELETED],
                      selectionMode: selectionMode,
                      selectionModeManager: selectionModeManager,
                    );
                  }
                } else {
                  return Text('Loading...',
                      style: TextStyle(color: Colors.grey));
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class AppBarTitle extends StatelessWidget {
  const AppBarTitle({
    Key? key,
    required final String roomId,
    required final void Function()? onTap,
  })  : _roomId = roomId,
        _onTap = onTap,
        super(key: key);

  final String _roomId;
  final void Function()? _onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _onTap,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(kDefaultPadding / 4.0),
            child: CircularGroupProfilePicture(
              roomId: _roomId,
              radius: kDefualtBorderRadius,
            ),
          ),
          SizedBox(width: kDefaultPadding / 4.0),
          TextStreamBuilder(
            stream: FirebaseService.getStreamToGroupData(roomId: _roomId),
            key: ChatDBDocumentField.GROUP_NAME,
          ),
        ],
      ),
    );
  }
}

class BodyIfMember extends StatelessWidget {
  const BodyIfMember({
    Key? key,
    required String roomId,
    required bool groupDeleted,
    required bool selectionMode,
    required selectionModeManager,
  })  : _roomId = roomId,
        _groupDeleted = groupDeleted,
        _selectionMode = selectionMode,
        _selectionModeManager = selectionModeManager,
        super(key: key);

  final String _roomId;
  final bool _groupDeleted;
  final bool _selectionMode;
  final _selectionModeManager;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseService.getStreamToChatRoomMessages(roomId: _roomId),
          builder: (context, snapshots) {
            //Setting last message as set whenever stream builder rebuilds itself
            FirebaseService.markLastMessageAsSeen(roomId: _roomId);
            List<Widget> messageList = [];
            messageList.add(SizedBox(
                height: kDefaultPadding *
                    4)); //To Provide Gap After last message so that it can go above the text field level
            if (snapshots.hasData && snapshots.data != null) {
              final messages = snapshots.data!.docs;
              for (final message in messages) {
                if (message[MessageDocumentField.DELETED_FOR_EVERYONE])
                  continue;
                if ((message[MessageDocumentField.DELETED_BY]
                        as Map<dynamic, dynamic>)
                    .containsKey(FirebaseService.currentUserEmail)) continue;
                final id = message[MessageDocumentField.MESSAGE_ID];
                final sender = message[MessageDocumentField.SENDER];
                final time = message[MessageDocumentField.TIME];
                final date = message[MessageDocumentField.DATE];
                final timeStamp = message[MessageDocumentField.TIME_STAMP];
                final type = message[MessageDocumentField.TYPE];

                String? content = message[MessageDocumentField.CONTENT] != null
                    ? EncryptionService.decrypt(
                        message[MessageDocumentField.CONTENT])
                    : null;

                if (type == MessageType.TEXT) {
                  messageList.add(
                    GroupTextMessage(
                      message: Message(
                        messageId: id,
                        sender: sender,
                        time: time,
                        date: date,
                        content: content,
                        timestamp: timeStamp,
                        type: type,
                      ),
                      selectionMode: _selectionMode,
                      selectionModeManager: _selectionModeManager,
                    ),
                  );
                } else if (type == MessageType.IMAGE) {
                  final List<String> imageUrl = [];
                  for (final url in message[MessageDocumentField.IMAGES]) {
                    imageUrl.add(EncryptionService.decrypt(url));
                  }
                  messageList.add(
                    GroupImageMessage(
                      message: Message(
                        messageId: id,
                        content: content,
                        imageUrls: imageUrl,
                        sender: sender,
                        time: time,
                        date: date,
                        timestamp: timeStamp,
                        type: type,
                      ),
                      selectionMode: _selectionMode,
                      selectionModeManager: _selectionModeManager,
                    ),
                  );
                }
              }
            }
            return ListView(children: messageList, reverse: true);
          },
        ),
        Positioned(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: _groupDeleted
                ? GroupDeleted()
                : GroupMessageTextField(
                    roomId: _roomId,
                  ),
          ),
          bottom: 0,
        )
      ],
    );
  }
}

class BodyIfNotMember extends StatelessWidget {
  const BodyIfNotMember({
    Key? key,
    required String roomId,
    required Timestamp removedAt,
    required bool selectionMode,
    required selectionModeManager,
  })  : _roomId = roomId,
        _removedAt = removedAt,
        _selectionMode = selectionMode,
        _selectionModeManager = selectionModeManager,
        super(key: key);

  final String _roomId;
  final Timestamp _removedAt;
  final bool _selectionMode;
  final _selectionModeManager;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseService.getStreamToRemovedChatRoomMessages(
              roomId: _roomId, removedAt: _removedAt),
          builder: (context, snapshots) {
            List<Widget> messageList = [];
            messageList.add(
              SizedBox(height: kDefaultPadding * 4),
            ); //To Provide Gap After last message so that it can go above the text field level
            if (snapshots.hasData && snapshots.data != null) {
              final messages = snapshots.data!.docs;
              for (final message in messages) {
                if (message[MessageDocumentField.DELETED_FOR_EVERYONE])
                  continue;
                if ((message[MessageDocumentField.DELETED_BY]
                        as Map<dynamic, dynamic>)
                    .containsKey(FirebaseService.currentUserEmail)) continue;
                final id = message[MessageDocumentField.MESSAGE_ID];
                final sender = message[MessageDocumentField.SENDER];
                final time = message[MessageDocumentField.TIME];
                final date = message[MessageDocumentField.DATE];
                final timeStamp = message[MessageDocumentField.TIME_STAMP];
                final type = message[MessageDocumentField.TYPE];

                String? content = message[MessageDocumentField.CONTENT] != null
                    ? EncryptionService.decrypt(
                        message[MessageDocumentField.CONTENT])
                    : null;

                if (type == MessageType.TEXT) {
                  messageList.add(
                    GroupTextMessage(
                      message: Message(
                        messageId: id,
                        sender: sender,
                        time: time,
                        date: date,
                        content: content,
                        timestamp: timeStamp,
                        type: type,
                      ),
                      selectionMode: _selectionMode,
                      selectionModeManager: _selectionModeManager,
                    ),
                  );
                } else if (type == MessageType.IMAGE) {
                  final List<String> imageUrl = [];
                  for (final url in message[MessageDocumentField.IMAGES]) {
                    imageUrl.add(EncryptionService.decrypt(url));
                  }
                  messageList.add(
                    GroupImageMessage(
                      message: Message(
                        messageId: id,
                        content: content,
                        imageUrls: imageUrl,
                        sender: sender,
                        time: time,
                        date: date,
                        timestamp: timeStamp,
                        type: type,
                      ),
                      selectionMode: _selectionMode,
                      selectionModeManager: _selectionModeManager,
                    ),
                  );
                }
              }
            }
            return ListView(children: messageList, reverse: true);
          },
        ),
        Positioned(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: NotMember(),
          ),
          bottom: 0,
        )
      ],
    );
  }
}

class NotMember extends StatelessWidget {
  const NotMember({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Center(
          child: Text(
        'You are no logner member of the group.',
        style: TextStyle(color: Colors.grey),
      )),
    );
  }
}

class GroupDeleted extends StatelessWidget {
  const GroupDeleted({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Center(
          child: Text(
        'This group no longer exist.',
        style: TextStyle(color: Colors.grey),
      )),
    );
  }
}
