import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/constants/firestore_costants.dart';
import 'package:hi/custom_widget/progressHud/progress_hud.dart';
import 'package:hi/custom_widget/stream_builders/circular_profile_picture.dart';
import 'package:hi/custom_widget/stream_builders/conditional_stream_builder.dart';
import 'package:hi/custom_widget/stream_builders/online_indicator_text.dart';
import 'package:hi/custom_widget/stream_builders/text_stream_builder.dart';
import 'package:hi/provider/selected_messages.dart';
import 'package:hi/screens/chat/one_to_one/components/image_message.dart';
import 'package:hi/screens/chat/one_to_one/components/message_text_field.dart';
import 'package:hi/screens/chat/one_to_one/components/text_message.dart';
import 'package:hi/screens/profile_view/user_profile_view_screen.dart';
import 'package:hi/services/encryption_service.dart';
import 'package:hi/services/firebase_service.dart';
import 'package:provider/provider.dart';
import 'dart:math' as Math;

class ChatRoom extends StatelessWidget {
  final String _roomId;
  final String _friendEmail;

  ChatRoom({required final String roomId, required final String friendEamil})
      : _roomId = roomId,
        _friendEmail = friendEamil;
  @override
  Widget build(BuildContext context) {
    return Body(
      roomId: _roomId,
      friendEmail: _friendEmail,
    );
  }
}

class Body extends StatefulWidget {
  const Body({
    Key? key,
    required String friendEmail,
    required String roomId,
  })  : _friendEmail = friendEmail,
        _roomId = roomId,
        super(key: key);

  final String _friendEmail;
  final String _roomId;

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
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
          backgroundColor:
              Theme.of(context).scaffoldBackgroundColor.withOpacity(.9),
          appBar: AppBar(
            title: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      UserProfileScreen(userEmail: widget._friendEmail),
                ),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(kDefaultPadding / 4.0),
                    child: CircularProfilePicture(
                      email: widget._friendEmail,
                      radius: kDefualtBorderRadius,
                    ),
                  ),
                  SizedBox(width: kDefaultPadding / 4.0),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextStreamBuilder(
                        stream: FirebaseService.getStreamToUserData(
                            email: widget._friendEmail),
                        key: UserDocumentField.DISPLAY_NAME,
                      ),
                      ConditionalStreamBuilder(
                        stream: FirebaseService.getStreamToFriendDoc(
                            email: widget._friendEmail),
                        childIfExist:
                            OnlineIndicatorText(email: widget._friendEmail),
                        childIfDoNotExist: Container(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
                          onPressed: () {},
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
            child: Stack(
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseService.getStreamToChatRoomMessages(
                      roomId: widget._roomId),
                  builder: (context, snapshots) {
                    //Setting last message as set whenever stream builder rebuilds itself
                    FirebaseService.markLastMessageAsSeen(
                        roomId: widget._roomId);
                    List<Widget> messageList = [];
                    messageList.add(
                      SizedBox(
                        height: kDefaultPadding * 4,
                      ),
                    ); //To Provide Gap After last message so that it can go above the text field level
                    if (snapshots.hasData && snapshots.data != null) {
                      final messages = snapshots.data!.docs;
                      for (final message in messages) {
                        if (message[MessageDocumentField.DELETED_FOR_EVERYONE])
                          continue;
                        if ((message[MessageDocumentField.DELETED_BY]
                                as Map<dynamic, dynamic>)
                            .containsKey(FirebaseService.currentUserEmail))
                          continue;
                        final id = message[MessageDocumentField.MESSAGE_ID];
                        final sender = message[MessageDocumentField.SENDER];
                        final time = message[MessageDocumentField.TIME];
                        final date = message[MessageDocumentField.DATE];
                        final timeStamp =
                            message[MessageDocumentField.TIME_STAMP];
                        final type = message[MessageDocumentField.TYPE];

                        String? content =
                            message[MessageDocumentField.CONTENT] != null
                                ? EncryptionService.decrypt(
                                    message[MessageDocumentField.CONTENT])
                                : null;

                        if (type == MessageType.TEXT) {
                          messageList.add(
                            TextMessage(
                              message: Message(
                                  messageId: id,
                                  sender: sender,
                                  time: time,
                                  date: date,
                                  content: content,
                                  timestamp: timeStamp),
                              selectionMode: selectionMode,
                              selectionModeManager: selectionModeManager,
                            ),
                          );
                        } else if (type == MessageType.IMAGE) {
                          final List<String> imageUrl = [];
                          for (final url
                              in message[MessageDocumentField.IMAGES]) {
                            imageUrl.add(EncryptionService.decrypt(url));
                          }
                          messageList.add(
                            ImageMessage(
                              message: Message(messageId: id, content: content, imageUrls: imageUrl, sender: sender, time: time, date: date, timestamp: timeStamp),
                              selectionMode: selectionMode, selectionModeManager: selectionModeManager,
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
                    child: ConditionalStreamBuilder(
                      stream: FirebaseService.getStreamToFriendDoc(
                          email: widget._friendEmail),
                      childIfExist: MessageTextField(
                        roomId: widget._roomId,
                        friendEmail: widget._friendEmail,
                      ),
                      childIfDoNotExist: NoLongerFriends(),
                    ),
                  ),
                  bottom: 0,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NoLongerFriends extends StatelessWidget {
  const NoLongerFriends({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Center(
          child: Text(
        'You are no logner friends.',
        style: TextStyle(color: Colors.grey),
      )),
    );
  }
}
