import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/constants/firestore_costants.dart';
import 'package:hi/custom_widget/stream_builders/circular_group_profile_picture.dart';
import 'package:hi/custom_widget/stream_builders/text_stream_builder.dart';
import 'package:hi/screens/chat/group_chat/components/group_image_message.dart';
import 'package:hi/screens/chat/group_chat/components/group_message_text_field.dart';
import 'package:hi/screens/chat/group_chat/components/group_text_message.dart';
import 'package:hi/services/encryption_service.dart';
import 'package:hi/services/firebase_service.dart';

class GroupChatRoom extends StatelessWidget {
  final String _roomId;

  GroupChatRoom({required final String roomId}) : _roomId = roomId;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
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
        backgroundColor: kPrimaryColor,
      ),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseService.getStreamToUserChatRef(roomId: _roomId),
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.data != null &&
                snapshot.data!.exists) {
              final doc = snapshot.data;
              if (doc![ChatDocumentField.REMOVED])
                return BodyIfNotMember(
                    roomId: _roomId,
                    removedAt: doc[ChatDocumentField.REMOVED_AT]);
              else
                return BodyIfMember(roomId: _roomId);
            } else {
              return Text('Loading...', style: TextStyle(color: Colors.grey));
            }
          },
        ),
      ),
    );
  }
}

class BodyIfMember extends StatelessWidget {
  const BodyIfMember({
    Key? key,
    required String roomId,
  })  : _roomId = roomId,
        super(key: key);

  final String _roomId;

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
                final id = message[MessageDocumentField.MESSAGE_ID];
                final sender = message[MessageDocumentField.SENDER];
                final time = message[MessageDocumentField.TIME];
                final type = message[MessageDocumentField.TYPE];

                String? content = message[MessageDocumentField.CONTENT] != null
                    ? EncryptionService.decrypt(
                        message[MessageDocumentField.CONTENT])
                    : null;

                if (type == MessageType.TEXT) {
                  messageList.add(
                    GroupTextMessage(
                      id: id,
                      sender: sender,
                      content: content as String,
                      time: time,
                    ),
                  );
                } else if (type == MessageType.IMAGE) {
                  final List<String> imageUrl = [];
                  for (final url in message[MessageDocumentField.IMAGES]) {
                    imageUrl.add(EncryptionService.decrypt(url));
                  }
                  messageList.add(
                    GroupImageMessage(
                      id: id,
                      sender: sender,
                      content: content,
                      time: time,
                      imageUrl: imageUrl,
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
            child: GroupMessageTextField(
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
  })  : _roomId = roomId,
        _removedAt = removedAt,
        super(key: key);

  final String _roomId;
  final Timestamp _removedAt;

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
                final id = message[MessageDocumentField.MESSAGE_ID];
                final sender = message[MessageDocumentField.SENDER];
                final time = message[MessageDocumentField.TIME];
                final type = message[MessageDocumentField.TYPE];

                String? content = message[MessageDocumentField.CONTENT] != null
                    ? EncryptionService.decrypt(
                        message[MessageDocumentField.CONTENT])
                    : null;

                if (type == MessageType.TEXT) {
                  messageList.add(
                    GroupTextMessage(
                      id: id,
                      sender: sender,
                      content: content as String,
                      time: time,
                    ),
                  );
                } else if (type == MessageType.IMAGE) {
                  final List<String> imageUrl = [];
                  for (final url in message[MessageDocumentField.IMAGES]) {
                    imageUrl.add(EncryptionService.decrypt(url));
                  }
                  messageList.add(
                    GroupImageMessage(
                      id: id,
                      sender: sender,
                      content: content,
                      time: time,
                      imageUrl: imageUrl,
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
