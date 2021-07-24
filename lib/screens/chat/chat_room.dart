import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/constants/firestore_costants.dart';
import 'package:hi/custom_widget/stream_builders/circular_profile_picture.dart';
import 'package:hi/custom_widget/stream_builders/text_stream_builder.dart';
import 'package:hi/screens/chat/components/message_text_field.dart';
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
              stream: FirebaseService.getStreamToChat(roomId: _roomId),
              builder: (context, snapshots) {
                List<Text> messageList = [];
                if (snapshots.hasData && snapshots.data != null) {
                  final messages = snapshots.data!.docs;
                  for (final message in messages) {
                    messageList
                        .add(Text(message[MessageDocumentField.CONTENT]));
                  }
                }
                return Expanded(child: ListView(children: messageList));
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
