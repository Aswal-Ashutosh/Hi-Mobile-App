import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/constants/firestore_costants.dart';
import 'package:hi/custom_widget/stream_builders/circular_profile_picture.dart';
import 'package:hi/custom_widget/stream_builders/text_stream_builder.dart';
import 'package:hi/screens/chat/components/message_text_field.dart';

class ChatRoom extends StatelessWidget {
  final String _roomId;
  final String _friendEamil;
  const ChatRoom(
      {required final String roomId, required final String friendEamil})
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
            Expanded(
              child: ListView(
                children: [
                  Text('Hi'),
                  Text('Hi'),
                  Text('Hi'),
                  Text('Hi'),
                  Text('Hi'),
                  Text('Hi'),
                  Text('Hi'),
                  Text('Hi'),
                  Text('Hi'),
                  Text('Hi'),
                  Text('Hi'),
                  Text('Hi'),
                  Text('Hi'),
                  Text('Hi'),
                  Text('Hi'),
                  Text('Hi'),
                  Text('Hi'),
                  Text('Hi'),
                  Text('Hi'),
                  Text('Hi'),
                  Text('Hi'),
                  Text('Hi'),
                  Text('Hi'),
                  Text('Hi'),
                  Text('Hi'),
                  Text('Hi'),
                  Text('Hi'),
                  Text('Hi'),
                  Text('Hi'),
                  Text('Hi'),
                  Text('Hi'),
                  Text('Hi'),
                ],
              ),
            ),
            MessageTextField()
          ],
        ),
      ),
    );
  }
}
