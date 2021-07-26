import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/constants/firestore_costants.dart';
import 'package:hi/custom_widget/stream_builders/circular_profile_picture.dart';
import 'package:hi/custom_widget/stream_builders/text_stream_builder.dart';
import 'package:hi/screens/chat/components/message_text_field.dart';
import 'package:hi/screens/chat/components/text_message.dart';
import 'package:hi/services/encryption_service.dart';
import 'package:hi/services/firebase_service.dart';

class ChatRoom extends StatelessWidget {
  final String _roomId;
  final String _friendEamil;
  final TextEditingController _textEditingController = TextEditingController();
  ChatRoom({required final String roomId, required final String friendEamil})
      : _roomId = roomId,
        _friendEamil = friendEamil;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(kDefaultPadding / 4.0),
          child: CircularProfilePicture(
            email: _friendEamil,
            radius: kDefualtBorderRadius,
          ),
        ),
        title: TextStreamBuilder(
            email: _friendEamil, key: UserDocumentField.DISPLAY_NAME),
        backgroundColor: kPrimaryColor,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseService.getStreamToChatRoom(roomId: _roomId),
              builder: (context, snapshots) {
                List<Widget> messageList = [];
                if (snapshots.hasData && snapshots.data != null) {
                  final messages = snapshots.data!.docs;
                  for (final message in messages) {
                    final id = message[MessageDocumentField.MESSAGE_ID];
                    final sender = message[MessageDocumentField.SENDER];
                    final content = EncryptionService.decrypt(message[MessageDocumentField.CONTENT]);
                    final time = message[MessageDocumentField.TIME];
                    messageList
                        .add(TextMessage(id: id, sender: sender, content: content, time: time));
                  }
                }
                return Expanded(child: ListView(children: messageList, reverse: true));
              },
            ),
            MessageTextField(
              controller: _textEditingController,
              onSend: () async {
                final message = _textEditingController.text.trim();
                if (message.isNotEmpty) {
                  _textEditingController.clear();
                  await FirebaseService.sendTextMessageToFriend(
                    friendEmail: _friendEamil,
                    roomId: _roomId,
                    message: message,
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
